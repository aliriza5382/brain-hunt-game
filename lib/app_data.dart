// lib/app_data.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppData {
  static List<String> oyuncular = [];
  static Map<String, int> puanlar = {};
  static int oyunSuresi = 60; // saniye cinsinden

  // Verileri kaydet
  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('oyuncular', oyuncular);
    await prefs.setString('puanlar', jsonEncode(puanlar));
    await prefs.setInt('oyunSuresi', oyunSuresi);
  }

  // Verileri yükle
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    oyuncular = prefs.getStringList('oyuncular') ?? [];
    final puanJson = prefs.getString('puanlar');
    if (puanJson != null) {
      puanlar = Map<String, int>.from(jsonDecode(puanJson));
    } else {
      puanlar = {};
    }
    oyunSuresi = prefs.getInt('oyunSuresi') ?? 60;
  }

  // Tüm verileri temizle
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('oyuncular');
    await prefs.remove('puanlar');
    await prefs.remove('oyunSuresi');
    oyuncular = [];
    puanlar = {};
    oyunSuresi = 60;
  }
}
