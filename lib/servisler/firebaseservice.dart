import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeller/calismagurubumodeli.dart';

class FirebaseService {
  final _koleksiyon =
      FirebaseFirestore.instance.collection('calismaguruplar');

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
}
