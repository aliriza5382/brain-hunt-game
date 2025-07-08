import 'package:flutter/material.dart';
import 'oyun_screen.dart';
import 'app_data.dart';

class OyuncuEklemeScreen extends StatefulWidget {
  const OyuncuEklemeScreen({super.key});

  @override
  State<OyuncuEklemeScreen> createState() => _OyuncuEklemeScreenState();
}

class _OyuncuEklemeScreenState extends State<OyuncuEklemeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  int? seciliSureDakika;
  final List<int> sureSecenekleriDakika = [1, 2, 3, 4, 5, 10];

  late AnimationController _animController;
  late Animation<double> _cardAnim;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _verileriYukle() async {
    await AppData.load();
    setState(() {
      seciliSureDakika = AppData.oyunSuresi ~/ 60;
      if (AppData.oyunSuresi == 60 && seciliSureDakika == 1) {
        seciliSureDakika = null;
      }
    });
  }

  Future<void> oyuncuEkle() async {
    final isim = controller.text.trim();
    if (isim.isNotEmpty && !AppData.oyuncular.contains(isim)) {
      setState(() {
        AppData.oyuncular.add(isim);
        AppData.puanlar[isim] = AppData.puanlar[isim] ?? 0;
        controller.clear();
      });
      await AppData.save();
    }
  }

  Future<void> oyuncuSil(int index) async {
    setState(() {
      AppData.puanlar.remove(AppData.oyuncular[index]);
      AppData.oyuncular.removeAt(index);
    });
    await AppData.save();
  }

  Future<void> skorSifirla() async {
    setState(() {
      for (final isim in AppData.oyuncular) {
        AppData.puanlar[isim] = 0;
      }
    });
    await AppData.save();
  }

  Future<void> oyunaBasla() async {
    if (AppData.oyuncular.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az 3 oyuncu gerekli!')),
      );
      return;
    }
    if (seciliSureDakika == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen süre seçin!')),
      );
      return;
    }
    AppData.oyunSuresi = seciliSureDakika! * 60;
    await AppData.save();

    final yeniPuanlar = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => OyunScreen(
          oyuncular: List<String>.from(AppData.oyuncular),
          puanlar: Map<String, int>.from(AppData.puanlar),
          sure: AppData.oyunSuresi,
        ),
      ),
    );

    if (yeniPuanlar != null) {
      setState(() {
        AppData.puanlar = Map<String, int>.from(yeniPuanlar);
      });
      await AppData.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final siraliOyuncular = List<String>.from(AppData.oyuncular)
      ..sort((a, b) =>
          (AppData.puanlar[b] ?? 0).compareTo(AppData.puanlar[a] ?? 0));
    String birinci = siraliOyuncular.isNotEmpty ? siraliOyuncular[0] : '';
    String ikinci = siraliOyuncular.length > 1 ? siraliOyuncular[1] : '';
    String ucuncu = siraliOyuncular.length > 2 ? siraliOyuncular[2] : '';

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Oyuncuları Ekle',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB388FF),
              Color(0xFF8C9EFF),
              Color(0xFFEDE7F6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),
                  // Animasyonlu puan sıralaması kartı
                  SizeTransition(
                    sizeFactor: _cardAnim,
                    axis: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Puan Sıralaması",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 19)),
                              const Divider(height: 18, thickness: 1.3),
                              if (birinci.isNotEmpty)
                                _puanRow(birinci, AppData.puanlar[birinci] ?? 0,
                                    1, Colors.amber, 19),
                              if (ikinci.isNotEmpty)
                                _puanRow(ikinci, AppData.puanlar[ikinci] ?? 0,
                                    2, Colors.grey.shade600, 17),
                              if (ucuncu.isNotEmpty)
                                _puanRow(ucuncu, AppData.puanlar[ucuncu] ?? 0,
                                    3, Colors.brown.shade400, 16),
                              ...siraliOyuncular.asMap().entries.map((entry) {
                                final isim = entry.value;
                                final sira = entry.key + 1;
                                if (sira <= 3) return const SizedBox.shrink();
                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 2.5),
                                  child: Row(
                                    children: [
                                      Text("$sira.",
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Text(isim,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      Text(
                                        "${AppData.puanlar[isim] ?? 0}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Oyuncu ekleme ve süre kutusu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple.shade50,
                                  Colors.deepPurple.shade100
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.13),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                labelText: 'Oyuncu İsmi',
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.person_add_alt_1),
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onSubmitted: (_) => oyuncuEkle(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 4,
                          child: DropdownButtonFormField<int>(
                            value: seciliSureDakika,
                            decoration: InputDecoration(
                              labelText: 'Süre',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                            ),
                            hint: const Text("Dakika"),
                            items: sureSecenekleriDakika
                                .map((dk) => DropdownMenuItem<int>(
                              value: dk,
                              child: Text('$dk dakika'),
                            ))
                                .toList(),
                            onChanged: (yeniSure) async {
                              setState(() {
                                seciliSureDakika = yeniSure;
                              });
                              AppData.oyunSuresi = yeniSure! * 60;
                              await AppData.save();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  // Oyuncu ekle & skor sıfırla butonları
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 20, color: Color(0xFFFFFFFF),),
                            label: const Text('Oyuncu Ekle', style: TextStyle(color: Color(0xFFFFFFFF)),),
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13)),
                            ),
                            onPressed: oyuncuEkle,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          flex: 4,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.restart_alt, color: Color(0xFFFFFFFF)),
                            label: const Text("Skorları Sıfırla", style: TextStyle(color: Color(0xFFFFFFFF)),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: siraliOyuncular.isEmpty ? null : skorSifirla,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Oyuncular listesi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Card(
                      color: Colors.white.withOpacity(0.93),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(19)),
                      elevation: 2,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        itemCount: AppData.oyuncular.length,
                        separatorBuilder: (_, __) => const Divider(height: 2),
                        itemBuilder: (_, i) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.shade100,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            AppData.oyuncular[i],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${AppData.puanlar[AppData.oyuncular[i]] ?? 0}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                    fontSize: 17),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => oyuncuSil(i),
                                tooltip: "Oyuncuyu Sil",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Oyuna başla butonu
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: oyunaBasla,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 6,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          shadowColor: Colors.deepPurpleAccent.withOpacity(0.13),
                        ),
                        child: const Text(
                          'Oyuna Başla',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2, color: Color(0xFFFFFFFF)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _puanRow(
      String isim, int puan, int sira, Color renk, double fontSize) {
    final madalya = sira == 1
        ? "🥇"
        : sira == 2
        ? "🥈"
        : sira == 3
        ? "🥉"
        : "$sira.";
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(madalya, style: TextStyle(fontSize: fontSize + 1)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isim,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: renk, fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "$puan",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: renk, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
