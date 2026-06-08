import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeller/calismagurubumodeli.dart';
import '../modeller/duyurumodeli.dart';

class FirebaseService {
  final _koleksiyon =
      FirebaseFirestore.instance.collection('calismaguruplar');

  final _duyurularKoleksiyon =
      FirebaseFirestore.instance.collection('duyurular');

  Stream<List<CalismaGrubuModeli>> gruplariGetir() {
    return _koleksiyon
        .orderBy('tarih', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CalismaGrubuModeli.fromFirestore(doc))
            .toList());
  }

  Future<void> grupEkle(CalismaGrubuModeli grup) async {
    await _koleksiyon.add(grup.toMap());
  }

  Future<void> grubaKatil(String grupId, String kullaniciAdi) async {
    await _koleksiyon.doc(grupId).update({
      'katilimcilar': FieldValue.arrayUnion([kullaniciAdi]),
    });
  }

  Stream<List<DuyuruModeli>> duyurulariGetir() {
    return _duyurularKoleksiyon
        .orderBy('tarih', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DuyuruModeli.fromFirestore(doc))
            .toList());
  }

  Future<void> duyuruEkle(DuyuruModeli duyuru) async {
    await _duyurularKoleksiyon.add(duyuru.toMap());
  }
}
