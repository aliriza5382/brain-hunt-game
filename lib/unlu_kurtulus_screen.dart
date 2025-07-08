import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sonuc_screen.dart';
import 'app_data.dart';

const List<String> unluListesi = [
  // Müzik ve Şarkıcılar
  "Tarkan",
  "Sezen Aksu",
  "Barış Manço",
  "Ajda Pekkan",
  "Hadise",
  "Mustafa Sandal",
  "Aleyna Tilki",
  "Zeki Müren",
  "İbrahim Tatlıses",
  "Haluk Levent",
  "Edis",

  // Dizi ve Sinema Oyuncuları
  "Kıvanç Tatlıtuğ",
  "Haluk Bilginer",
  "Kenan İmirzalioğlu",
  "Çağatay Ulusoy",
  "Engin Altan Düzyatan",
  "Serenay Sarıkaya",
  "Burak Özçivit",

  // Komedyenler ve TV
  "Cem Yılmaz",
  "Şahan Gökbakar",
  "Ata Demirer",
  "Tolga Çevik",
  "Yılmaz Erdoğan",
  "Beyazıt Öztürk",
  "Acun Ilıcalı",
  "Müge Anlı",
  "Esra Erol",
  "Serdar Ortaç",

  // Sporcular
  "Arda Turan",
  "Fatih Terim",
  "Alex de Souza",
  "Volkan Demirel",
  "Burak Yılmaz",
  "Kenan Sofuoğlu",
  "Sergen Yalçın",

  // Fenomen ve Sosyal Medya
  "Nusret",
  "Enes Batur",
  "Danla Bilic",
  "Reynmen",
  "Orkun Işıtmak",

  // Dünya Ünlüleri (Karıştırmak için ekstra)
  "Lionel Messi",
  "Cristiano Ronaldo",
  "Elon Musk",
  "Brad Pitt",
  "Shakira",
];

class UnluKurtulusScreen extends StatefulWidget {
  final String casusIsim;
  final List<String> oyuncular;
  final Map<String, int> puanlar;
  final void Function(Map<String, int>)? onSonuc;
  final int sure; // opsiyonel, default: 100

  const UnluKurtulusScreen({
    required this.casusIsim,
    required this.oyuncular,
    required this.puanlar,
    this.onSonuc,
    this.sure = 100,
    super.key,
  });

  @override
  State<UnluKurtulusScreen> createState() => _UnluKurtulusScreenState();
}

class _UnluKurtulusScreenState extends State<UnluKurtulusScreen> {
  late String secilenUnlu;
  String? mesaj;
  final TextEditingController tahminController = TextEditingController();

  bool onUyariGoster = true;
  bool kartGosteriliyor = false;
  bool tahminEkraninda = false;

  late int kalanSaniye;
  Timer? _timer;

  // Çift tıklama kontrolü için ek değişkenler
  int _bildimTik = 0;
  String _bildimMesaj = "";

  @override
  void initState() {
    super.initState();
    secilenUnlu = (List<String>.from(unluListesi)..shuffle()).first;
    kalanSaniye = widget.sure;
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _baslatTimer() {
    _timer?.cancel();
    kalanSaniye = widget.sure;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (kalanSaniye > 0) {
          kalanSaniye--;
        }
        if (kalanSaniye == 0) {
          kartGosteriliyor = false;
          tahminEkraninda = true;
          _timer?.cancel();
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradientBg = const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFF8FFAE), Color(0xFF4A00E0), Color(0xFF8E2DE2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

    if (onUyariGoster) {
      return Scaffold(
        body: Container(
          decoration: gradientBg,
          child: Center(
            child: Card(
              elevation: 18,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              color: Colors.deepOrange.shade50.withOpacity(0.98),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange, size: 66),
                    const SizedBox(height: 28),
                    const Text(
                      "TELEFONU CASUSA GÖSTERMEYİN!",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.deepOrange),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 26),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.visibility, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        elevation: 5,
                      ),
                      onPressed: () async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        await SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.landscapeRight,
                        ]);
                        setState(() {
                          onUyariGoster = false;
                          kartGosteriliyor = true;
                          kalanSaniye = widget.sure;
                          tahminEkraninda = false;
                        });
                        _baslatTimer();
                      },
                      label: const Text("ÜNLÜYÜ GÖSTER", style: TextStyle(color: Color(0xFFFFFFFF))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (kartGosteriliyor) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Container(
            decoration: gradientBg,
            child: Stack(
              children: [
                Center(
                  child: Card(
                    elevation: 30,
                    shadowColor: Colors.deepPurpleAccent.withOpacity(0.22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                    color: Colors.white,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.75,
                      alignment: Alignment.center,
                      child: Transform.rotate(
                        angle: -pi / 4320,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            secilenUnlu,
                            style: const TextStyle(
                              fontSize: 85,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              letterSpacing: 3.2,
                              shadows: [
                                Shadow(color: Colors.deepPurpleAccent, blurRadius: 12)
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 40,
                  child: Card(
                    color: Colors.deepOrange,
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          "$kalanSaniye",
                          key: ValueKey(kalanSaniye),
                          style: const TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Çift tıklama ile geçiş
                Positioned(
                  bottom: 44,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6D5BFF), Color(0xFF9686FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.21),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 17),
                          label: const Text(
                            "Ünlüyü Bildim",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                            minimumSize: const Size(80, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Colors.white24, width: 1),
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            splashFactory: InkRipple.splashFactory,
                          ),
                          onPressed: () async {
                            setState(() {
                              _bildimTik++;
                              if (_bildimTik == 1) {
                                _bildimMesaj = "Geçmek için bir daha bas!";
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted && _bildimTik < 2) {
                                    setState(() {
                                      _bildimTik = 0;
                                      _bildimMesaj = "";
                                    });
                                  }
                                });
                              } else if (_bildimTik >= 2) {
                                _bildimMesaj = "";
                                _bildimTik = 0;
                                kartGosteriliyor = false;
                                tahminEkraninda = true;
                                _timer?.cancel();
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.portraitUp,
                                  DeviceOrientation.portraitDown,
                                ]);
                              }
                            });
                          },
                        ),
                      ),
                      if (_bildimMesaj.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            _bildimMesaj,
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (tahminEkraninda) {
      return Scaffold(
        body: Container(
          decoration: gradientBg,
          child: Center(
            child: Card(
              elevation: 13,
              color: Colors.white.withOpacity(0.97),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 44),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology_alt_rounded, color: Colors.deepPurple.shade300, size: 54),
                    const SizedBox(height: 20),
                    const Text(
                      "Süre doldu! Casusun tahmin hakkı:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.deepPurple),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: tahminController,
                      style: const TextStyle(fontSize: 21),
                      decoration: InputDecoration(
                        labelText: 'Tahminin nedir?',
                        labelStyle: TextStyle(color: Colors.deepPurple.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(Icons.edit, color: Colors.deepPurple),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                      ),
                      onSubmitted: (_) => tahminEt(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: tahminEt,
                      label: const Text('Tahmin Et', style: TextStyle(color: Color(0xFFFFFFFF)),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (mesaj != null) {
      return Scaffold(
        body: Container(
          decoration: gradientBg,
          child: Center(
            child: Card(
              elevation: 10,
              color: Colors.white.withOpacity(0.97),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_emotions, color: Colors.amber.shade700, size: 62),
                    const SizedBox(height: 20),
                    Text(
                      mesaj!,
                      style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  void tahminEt() {
    final tahmin = tahminController.text.trim();
    if (tahmin.isEmpty) return;

    final yeniPuanlar = Map<String, int>.from(widget.puanlar);
    String mesajText;
    if (tahmin.toLowerCase() == secilenUnlu.toLowerCase()) {
      mesajText = "Tebrikler, casus kurtuldu!";
      yeniPuanlar[widget.casusIsim] = (yeniPuanlar[widget.casusIsim] ?? 0) + 1;
    } else {
      mesajText = "Yanlış tahmin! Ünlü: $secilenUnlu\nCasus ceza alıyor!";
      yeniPuanlar[widget.casusIsim] = (yeniPuanlar[widget.casusIsim] ?? 0) - 1;
      for (final isim in widget.oyuncular) {
        if (isim != widget.casusIsim) {
          yeniPuanlar[isim] = (yeniPuanlar[isim] ?? 0) + 1;
        }
      }
    }

    AppData.oyuncular = List<String>.from(widget.oyuncular);
    AppData.puanlar = Map<String, int>.from(yeniPuanlar);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SonucEkrani(
          mesaj: mesajText,
          oyuncular: widget.oyuncular,
          puanlar: yeniPuanlar,
          sure: widget.sure,
        ),
      ),
    );
  }
}
