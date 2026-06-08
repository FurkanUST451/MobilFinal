import 'package:flutter/material.dart';
import 'sharedpreferencesservice.dart';

class TemaProvider extends ChangeNotifier {
  bool _karanlik = false;
  bool get karanlik => _karanlik;
  ThemeMode get temaMode => _karanlik ? ThemeMode.dark : ThemeMode.light;

  Future<void> temaYukle() async {
    _karanlik = await SharedPreferencesService().temaGetir();
    notifyListeners();
  }

  void temaDegistir(bool deger) {
    _karanlik = deger;
    SharedPreferencesService().temaKaydet(deger);
    notifyListeners();
  }
}
