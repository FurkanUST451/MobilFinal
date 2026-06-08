class KullaniciModeli {
  final int? id;
  final String ad;
  final String soyad;
  final String email;
  final String fotoUrl;

  KullaniciModeli({
    this.id,
    required this.ad,
    required this.soyad,
    required this.email,
    required this.fotoUrl,
  });

  factory KullaniciModeli.fromMap(Map<String, dynamic> map) {
    return KullaniciModeli(
      id: map['id'] as int?,
      ad: map['ad'] as String? ?? '',
      soyad: map['soyad'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fotoUrl: map['fotoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ad': ad,
      'soyad': soyad,
      'email': email,
      'fotoUrl': fotoUrl,
    };
  }

  String get tamAd => '$ad $soyad';
}
