import 'package:cloud_firestore/cloud_firestore.dart';

class DuyuruModeli {
  final String? id;
  final String baslik;
  final String icerik;
  final String yazar;
  final String tarih;

  DuyuruModeli({
    this.id,
    required this.baslik,
    required this.icerik,
    required this.yazar,
    required this.tarih,
  });

  factory DuyuruModeli.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DuyuruModeli(
      id: doc.id,
      baslik: data['baslik'] as String? ?? '',
      icerik: data['icerik'] as String? ?? '',
      yazar: data['yazar'] as String? ?? '',
      tarih: data['tarih'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baslik': baslik,
      'icerik': icerik,
      'yazar': yazar,
      'tarih': tarih,
    };
  }
}
