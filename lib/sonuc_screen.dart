import 'package:flutter/material.dart';
import 'oyun_screen.dart';
import 'oyuncu_ekleme_screen.dart';
import 'app_data.dart';

class SonucEkrani extends StatelessWidget {
  final String mesaj;
  final List<String> oyuncular;
  final Map<String, int> puanlar;
  final int sure;

  const SonucEkrani({
    required this.mesaj,
    required this.oyuncular,
    required this.puanlar,
    required this.sure,
    super.key,
  });

  void yeniTurBaslat(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OyunScreen(
          oyuncular: List<String>.from(oyuncular),
          puanlar: Map<String, int>.from(puanlar),
          sure: sure,
        ),
      ),
    );
  }

  Future<void> anaMenuyeDon(BuildContext context) async {
    AppData.oyuncular = List<String>.from(oyuncular);
    AppData.puanlar = Map<String, int>.from(puanlar);
    await AppData.save();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const OyuncuEklemeScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final siraliOyuncular = List<String>.from(oyuncular)
      ..sort((a, b) => (puanlar[b] ?? 0).compareTo(puanlar[a] ?? 0));

    String birinci = siraliOyuncular.isNotEmpty ? siraliOyuncular[0] : '';
    String ikinci = siraliOyuncular.length > 1 ? siraliOyuncular[1] : '';
    String ucuncu = siraliOyuncular.length > 2 ? siraliOyuncular[2] : '';

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text('Sonuçlar', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.home, size: 28, color: Colors.white),
              tooltip: "Ana Menü",
              onPressed: () => anaMenuyeDon(context),
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0), Color(0xFFF8FFAE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.13),
                              blurRadius: 32,
                              offset: const Offset(0, 14),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            AnimatedScale(
                              scale: 1.18,
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.elasticOut,
                              child: Icon(
                                mesaj.toLowerCase().contains("kazandı") ||
                                    mesaj.toLowerCase().contains("kurtuldu")
                                    ? Icons.emoji_events_rounded
                                    : Icons.sentiment_dissatisfied_rounded,
                                size: 88,
                                color: mesaj.toLowerCase().contains("kazandı") ||
                                    mesaj.toLowerCase().contains("kurtuldu")
                                    ? Colors.amber.shade700
                                    : Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              mesaj,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                                shadows: [
                                  Shadow(
                                    color: Colors.deepPurpleAccent,
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 22),
                            if (birinci.isNotEmpty)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("🥇", style: TextStyle(fontSize: 27)),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          birinci,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                            fontSize: 20,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        " (${puanlar[birinci]})",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade700,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (ikinci.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text("🥈", style: TextStyle(fontSize: 23)),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              ikinci,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 18,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            " (${puanlar[ikinci]})",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (ucuncu.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text("🥉", style: TextStyle(fontSize: 21)),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              ucuncu,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.brown,
                                                fontSize: 17,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            " (${puanlar[ucuncu]})",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.brown,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 38),
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white.withOpacity(0.96),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            children: [
                              const Text("Puan Tablosu",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.deepPurple,
                                  )),
                              const Divider(thickness: 1, height: 16),
                              ...siraliOyuncular.map(
                                    (isim) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          isim,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        "${puanlar[isim] ?? 0}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.deepPurple.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 38),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              label: const Text(
                                "Yeni Tur Başlat",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 5,
                              ),
                              onPressed: () => yeniTurBaslat(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
