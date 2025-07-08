import 'package:flutter/material.dart';
import 'oyuncu_ekleme_screen.dart';
import 'app_data.dart'; // AppData sınıfını içe aktar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppData.load(); // Verileri yükle
  runApp(const KelimeCasusuApp());
}

class KelimeCasusuApp extends StatelessWidget {
  const KelimeCasusuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelime Casusu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const OyuncuEklemeScreen(), // Kaydedilmiş verilerle devam eder
    );
  }
}
