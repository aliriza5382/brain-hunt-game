import 'dart:math';
import 'package:flutter/material.dart';
import 'app_data.dart';
import 'unlu_kurtulus_screen.dart';
import 'sonuc_screen.dart';

// Sadece karışık kelimeler! (Kavram, nesne, hayvan, mekan, meslek vs.)
// Hiçbirinde özel isim, kişi, şehir veya marka yok.
const List<String> karisikKelimeler = [
  // Doğa ve Hayvanlar
  "Çiçek", "Karpuz", "Arı", "Ayı", "Kum", "Yaprak", "Çamur", "Kelebek", "Karga",
  "Martı", "Balık", "Tavuk", "Köpek", "Kedi", "Kuş", "Kertenkele", "Deniz",
  "Güneş", "Ay", "Bulut", "Dağ", "Orman", "Çöl", "Buz", "Şimşek", "Kar",

  // Yiyecek & İçecekler
  "Limonata", "Makarna", "Karpuz", "Börek", "Çorba", "Dondurma", "Pide",
  "Çay", "Kahve", "Pizza", "Pilav", "Kek", "Tost", "Sandviç", "Bal", "Yumurta",
  "Süt", "Salata", "Kurabiye", "Kebap", "Baklava", "Mısır", "Biber", "Salam",

  // Gündelik Eşyalar & Kavramlar
  "Sandalye", "Masa", "Çorap", "Anahtar", "Bardak", "Telefon", "Çanta",
  "Kalem", "Defter", "Silgi", "Saat", "Gözlük", "Şemsiye", "Çekiç", "Halı",
  "Ampul", "Koltuk", "Kitap", "Makas", "Tarık", "Düğme", "Kapı", "Yastık",
  "Makas", "Şişe", "Elbise", "Ayakkabı", "Tarak", "Peçete", "Kavanoz",
  "Tabak", "Bıçak", "Çatal", "Kaşık",

  // Duygular ve Kavramlar
  "Mutluluk", "Korku", "Sevinç", "Üzüntü", "Yalnızlık", "Aşk", "Nefret",
  "Sabır", "Heyecan", "Öfke", "Gurur", "Sürpriz", "Şans", "Hayal", "Huzur",

  // Mekanlar & Ulaşım
  "Kütüphane", "Okul", "Hastane", "Sinema", "Park", "Müze", "Hapishane",
  "Bahçe", "Kafe", "Fırın", "Tiyatro", "Plaj", "Otobüs", "Uçak", "Araba",
  "Tren", "Vapur", "Bisiklet", "Köprü", "Yol", "Cadde", "Sokak",

  // Meslek ve Ünvanlar
  "Doktor", "Öğretmen", "Hakim", "Pilot", "Garson", "Polis", "Şoför",
  "Aşçı", "Çiftçi", "Mühendis", "Kasiyer", "Yazılımcı", "Sanatçı",
  "Berber", "Tamirci", "Avukat",

  // Fantastik & Mizahi
  "Uzaylı", "Canavar", "Büyücü", "Peri", "Sihirbaz", "Robot", "Zombi",
  "Dinozor", "Ejderha", "Vampir", "Prens", "Prenses", "Korsan",

  // Duyular, eylemler ve hareket
  "Yüzme", "Zıplama", "Dans", "Koşu", "Uçmak", "Saklanmak", "Korkmak",
  "Uyumak", "Gülmek", "Ağlamak", "Konuşmak", "Bağırmak", "Düşmek",
  "Yazmak", "Çizmek", "Yemek", "İçmek", "Oynamak",

  // Renkler
  "Kırmızı", "Yeşil", "Mavi", "Sarı", "Turuncu", "Mor", "Beyaz", "Siyah", "Pembe", "Gri",

  // Diğer
  "Balon", "Çizgi", "Karton", "Harita", "Çember", "Fener", "Mum", "Zil", "Klavye", "Fare", "Boya",
];

class OyunScreen extends StatefulWidget {
  final List<String> oyuncular;
  final Map<String, int> puanlar;
  final int sure; // Saniye

  const OyunScreen({
    required this.oyuncular,
    required this.puanlar,
    required this.sure,
    super.key,
  });

  @override
  State<OyunScreen> createState() => _OyunScreenState();
}

class _OyunScreenState extends State<OyunScreen> {
  late List<String> _oyuncular;
  late String casus;
  late String kelime;

  int kartSira = 0;
  bool kartlarDagitildi = false;
  bool bosKartGosteriliyor = true;
  late int kalanSure;
  bool soruCevapAsamasi = false;
  bool oylamaHazir = false;
  Set<String> erkenOylamaIsteyenler = {};

  bool oylamaEkraniAcildi = false;

  @override
  void initState() {
    super.initState();
    _oyuncular = List<String>.from(AppData.oyuncular);
    casus = _oyuncular[Random().nextInt(_oyuncular.length)];
    kelime = (List<String>.from(karisikKelimeler)..shuffle()).first;

    bosKartGosteriliyor = true;
    kalanSure = widget.sure;
    soruCevapAsamasi = false;
    oylamaHazir = false;
    erkenOylamaIsteyenler.clear();
  }

  void bosKartSonraGercekKart() {
    setState(() {
      bosKartGosteriliyor = false;
    });
  }

  void kartiGordum() {
    setState(() {
      bosKartGosteriliyor = true;
      if (kartSira < _oyuncular.length - 1) {
        kartSira++;
      } else {
        kartlarDagitildi = true;
        soruCevapAsamasi = true;
        startTimer();
      }
    });
  }

  void startTimer() {
    Future.doWhile(() async {
      if (!mounted || kalanSure <= 0 || oylamaHazir) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (!oylamaHazir && mounted) {
        setState(() {
          kalanSure--;
          if (kalanSure <= 0) {
            oylamaHazir = true;
          }
        });
      }
      return !oylamaHazir && kalanSure > 0;
    });
  }

  void erkenOylamaIste(String oyuncu) {
    setState(() {
      erkenOylamaIsteyenler.add(oyuncu);
      if (erkenOylamaIsteyenler.length > _oyuncular.length ~/ 2) {
        oylamaHazir = true;
      }
    });
  }

  void casusuOylamaEkraninaGit() async {
    final yeniPuanlar = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => CasusOylamaScreen(
          oyuncular: _oyuncular,
          casus: casus,
          kelime: kelime,
          sure: widget.sure,
          puanlar: Map<String, int>.from(AppData.puanlar),
        ),
      ),
    );
    if (yeniPuanlar != null) {
      setState(() {
        AppData.puanlar = Map<String, int>.from(yeniPuanlar);
      });
      Navigator.pop(context, yeniPuanlar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientBg = const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0), Color(0xFFF8FFAE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

    // --- KARTLAR DAĞITILIYOR ---
    if (!kartlarDagitildi) {
      // Boş kart: Herkes bakmasın ekranı
      if (bosKartGosteriliyor) {
        return Scaffold(
          body: Container(
            decoration: gradientBg,
            child: Center(
              child: Card(
                elevation: 18,
                shadowColor: Colors.deepPurpleAccent.withOpacity(0.19),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                color: Colors.white.withOpacity(0.97),
                child: Padding(
                  padding: const EdgeInsets.all(42),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_off, size: 76, color: Colors.deepPurple.shade200),
                      const SizedBox(height: 24),
                      Text(
                        "Telefonu eline alan OYUNCU için",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.deepPurple.shade800,
                          shadows: [
                            Shadow(
                              color: Colors.deepPurple.shade100,
                              blurRadius: 10,
                            )
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        "Şimdi sadece\n'SIRADAKİ KARTI GÖSTER' butonuna basacak kişi ekrana bakmalı.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 36),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.remove_red_eye, color: Color(0xFFFFFFFF),),
                        label: const Text("SIRADAKİ KARTI GÖSTER", style: TextStyle(color: Color(0xFFFFFFFF)),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        onPressed: bosKartSonraGercekKart,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
      // Gerçek kart: Sadece oyuncuya göster
      else {
        final mevcutOyuncu = _oyuncular[kartSira];
        final kisiCasusMu = mevcutOyuncu == casus;
        return Scaffold(
          body: Container(
            decoration: gradientBg,
            child: Center(
              child: Card(
                elevation: 22,
                shadowColor: kisiCasusMu
                    ? Colors.red.withOpacity(0.19)
                    : Colors.green.withOpacity(0.18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
                color: kisiCasusMu ? Colors.red.shade50 : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 42),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Şimdi Sadece",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                          color: Colors.grey[800],
                          shadows: [Shadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        mevcutOyuncu,
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: kisiCasusMu ? Colors.red.shade700 : Colors.deepPurple.shade900,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 5, offset: Offset(1,2))
                            ]
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 30),
                      kisiCasusMu
                          ? Column(
                        children: [
                          const Text(
                            "Sen CASUSSUN!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Colors.red,
                                shadows: [
                                  Shadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  )
                                ]
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          Icon(Icons.visibility, color: Colors.red, size: 42),
                        ],
                      )
                          : Column(
                        children: [
                          Text(
                            "Kelime:",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade200.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              kelime,
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(color: Colors.black26, blurRadius: 2),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward, color: Color(0xFFFFFFFF),),
                        label: Text(
                          kartSira < _oyuncular.length - 1
                              ? "Kartı Gördüm, Sonrakine Ver"
                              : "Kartları Bitir ve Oyuna Başla",
                          style: const TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kisiCasusMu ? Colors.red : Colors.green.shade700,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        onPressed: kartiGordum,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    // --- SORU-CEVAP AŞAMASI ---
    if (soruCevapAsamasi && !oylamaHazir) {
      return Scaffold(
        body: Container(
          decoration: gradientBg,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                  color: Colors.deepPurple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(26),
                    child: Column(
                      children: [
                        Text(
                          "Süre: ${kalanSure ~/ 60}:${(kalanSure % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                        const SizedBox(height: 12),
                        const Text("Oyuncular birbirine evet-hayır soruları sorabilir.\nÇoğunluk erken oylama isterse oyun oylamaya geçer.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView(
                    children: _oyuncular.map((isim) {
                      final isteyen = erkenOylamaIsteyenler.contains(isim);
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        color: isteyen ? Colors.orange.shade50 : Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade100,
                              child: Text(isim[0], style: const TextStyle(color: Colors.deepPurple, fontSize: 22, fontWeight: FontWeight.bold))),
                          title: Text(
                            isim,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: isteyen
                              ? const Text("Erken oylama istiyor!", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w700))
                              : null,
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isteyen ? Colors.orange : Colors.deepPurple,
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: isteyen ? null : () => erkenOylamaIste(isim),
                            child: const Text("Erken Oylama", style: TextStyle(color: Color(0xFFFFFFFF)),),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Text("Çoğunluk isterse veya süre biterse oylama başlar.",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    }

    // --- OYLAMA EKRANINA TEK SEFERLİK GEÇİŞ ---
    if (oylamaHazir) {
      if (!oylamaEkraniAcildi) {
        oylamaEkraniAcildi = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          casusuOylamaEkraninaGit();
        });
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// ==================== OYLAMA EKRANI ====================

class CasusOylamaScreen extends StatefulWidget {
  final List<String> oyuncular;
  final String casus;
  final String kelime;
  final int sure;
  final Map<String, int> puanlar;

  const CasusOylamaScreen({
    required this.oyuncular,
    required this.casus,
    required this.kelime,
    required this.sure,
    required this.puanlar,
    super.key,
  });

  @override
  State<CasusOylamaScreen> createState() => _CasusOylamaScreenState();
}

class _CasusOylamaScreenState extends State<CasusOylamaScreen> {
  int oySirasinda = 0;
  late List<String?> oylananlar;
  bool oylarBitti = false;

  @override
  void initState() {
    super.initState();
    oylananlar = List.filled(widget.oyuncular.length, null);
  }

  void oyuKaydet(String secilen) {
    setState(() {
      oylananlar[oySirasinda] = secilen;
      if (oySirasinda < widget.oyuncular.length - 1) {
        oySirasinda++;
      } else {
        oylarBitti = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradientBg = const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0), Color(0xFFF8FFAE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

    if (!oylarBitti) {
      final mevcutOyuncu = widget.oyuncular[oySirasinda];
      return Scaffold(
        body: Container(
          decoration: gradientBg,
          child: Center(
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              color: Colors.white.withOpacity(0.98),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.how_to_vote, size: 52, color: Colors.deepPurple.shade400),
                    const SizedBox(height: 18),
                    Text(
                      '$mevcutOyuncu,\ncasus olduğunu düşündüğün kişiyi seç:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 28),
                    ...widget.oyuncular.map(
                          (isim) => RadioListTile<String>(
                        title: Text(isim, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                        value: isim,
                        activeColor: Colors.deepPurple,
                        groupValue: oylananlar[oySirasinda],
                        onChanged: (val) => oyuKaydet(val!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Oylama sırası: ${oySirasinda + 1} / ${widget.oyuncular.length}',
                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Oylama bittiğinde en çok oy alanı bul
      final Map<String, int> oySayilari = {};
      for (final secim in oylananlar) {
        if (secim != null) {
          oySayilari[secim] = (oySayilari[secim] ?? 0) + 1;
        }
      }
      String? enCokOyAlan;
      int enCokOy = 0;
      oySayilari.forEach((isim, oy) {
        if (oy > enCokOy) {
          enCokOy = oy;
          enCokOyAlan = isim;
        }
      });

      final casusYakalandi = enCokOyAlan == widget.casus;
      if (casusYakalandi) {
        // Casus yakalandıysa UnluKurtulusScreen'e yönlendir ve skorları ana menüye gönder
        return UnluKurtulusScreen(
          casusIsim: widget.casus,
          oyuncular: widget.oyuncular,
          puanlar: Map<String, int>.from(widget.puanlar),
          onSonuc: (guncelPuanlar) {
            Navigator.pop(context, guncelPuanlar);
          },
        );
      } else {
        final yeniPuanlar = Map<String, int>.from(widget.puanlar);
        yeniPuanlar[widget.casus] = (yeniPuanlar[widget.casus] ?? 0) + 1;
        return SonucEkrani(
          mesaj: "Casus kaçtı! (Kazandı)",
          oyuncular: widget.oyuncular,
          puanlar: yeniPuanlar,
          sure: widget.sure,
        );
      }
    }
  }
}
