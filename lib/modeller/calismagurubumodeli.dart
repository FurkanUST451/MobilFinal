import 'package:cloud_firestore/cloud_firestore.dart';

class CalismaGrubuModeli {
  final String? id;
  final String ad;
  final String ders;
  final String aciklama;
  final String olusturan;
  final List<String> katilimcilar;
  final String tarih;
  final String konum;
  final int maxKapasite;
  final String gorselUrl;

  CalismaGrubuModeli({
    this.id,
    required this.ad,
    required this.ders,
    required this.aciklama,
    required this.olusturan,
    required this.katilimcilar,
    required this.tarih,
    required this.konum,
    required this.maxKapasite,
    required this.gorselUrl,
  });

  factory CalismaGrubuModeli.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalismaGrubuModeli(
      id: doc.id,
      ad: data['ad'] as String? ?? '',
      ders: data['ders'] as String? ?? '',
      aciklama: data['aciklama'] as String? ?? '',
      olusturan: data['olusturan'] as String? ?? '',
      katilimcilar: List<String>.from(data['katilimcilar'] ?? []),
      tarih: data['tarih'] as String? ?? '',
      konum: data['konum'] as String? ?? '',
      maxKapasite: (data['maxKapasite'] as num?)?.toInt() ?? 10,
      gorselUrl: data['gorselUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'ders': ders,
      'aciklama': aciklama,
      'olusturan': olusturan,
      'katilimcilar': katilimcilar,
      'tarih': tarih,
      'konum': konum,
      'maxKapasite': maxKapasite,
      'gorselUrl': gorselUrl,
    };
  }
}
