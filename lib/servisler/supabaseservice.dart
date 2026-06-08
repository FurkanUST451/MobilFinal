import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<String> grupGorseliYukle(File resim) async {
    final dosyaAdi = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final yol = 'gruplar/$dosyaAdi';
    await _client.storage.from('grup-gorselleri').upload(yol, resim);
    return _client.storage.from('grup-gorselleri').getPublicUrl(yol);
  }

  Future<String> profilFotosuYukle(File foto) async {
    final dosyaAdi = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final yol = 'profiller/$dosyaAdi';
    await _client.storage.from('profil-fotograflari').upload(yol, foto);
    return _client.storage.from('profil-fotograflari').getPublicUrl(yol);
  }
}
