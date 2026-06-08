import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../modeller/calismagurubumodeli.dart';
import '../servisler/firebaseservice.dart';
import '../servisler/sqliteservice.dart';
import '../servisler/supabaseservice.dart';
import '../widgetlar/components/custombutton.dart';
import '../widgetlar/global/customappbar.dart';
import '../widgetlar/global/custombottomnavbar.dart';

class GrupOlusturEkrani extends StatefulWidget {
  const GrupOlusturEkrani({super.key});

  @override
  State<GrupOlusturEkrani> createState() => _GrupOlusturEkraniState();
}

class _GrupOlusturEkraniState extends State<GrupOlusturEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _dersController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _konumController = TextEditingController();
  final _maxKapasiteController = TextEditingController(text: '10');
  File? _secilenResim;
  bool _yukleniyor = false;

  Future<void> _resimSec() async {
    final picker = ImagePicker();
    final secilen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (secilen != null) {
      setState(() => _secilenResim = File(secilen.path));
    }
  }

  Future<void> _grubOlustur() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _yukleniyor = true);

    try {
      String gorselUrl = '';
      if (_secilenResim != null) {
        gorselUrl = await SupabaseService().grupGorseliYukle(_secilenResim!);
      }

      final kullanici = await SqliteService().kullaniciGetir();
      final olusturan =
          kullanici != null ? kullanici.tamAd : 'Furkan Berk Usta';

      final yeniGrup = CalismaGrubuModeli(
        ad: _adController.text.trim(),
        ders: _dersController.text.trim(),
        aciklama: _aciklamaController.text.trim(),
        olusturan: olusturan,
        katilimcilar: [],
        tarih: DateTime.now().toLocal().toString().substring(0, 10),
        konum: _konumController.text.trim(),
        maxKapasite: int.tryParse(_maxKapasiteController.text.trim()) ?? 10,
        gorselUrl: gorselUrl,
      );

      await FirebaseService().grupEkle(yeniGrup);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grup başarıyla oluşturuldu!')),
        );
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    } finally {
      setState(() => _yukleniyor = false);
    }
  }

  @override
  void dispose() {
    _adController.dispose();
    _dersController.dispose();
    _aciklamaController.dispose();
    _konumController.dispose();
    _maxKapasiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yeni Çalışma Grubu',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _adController,
                      decoration: const InputDecoration(
                        labelText: 'Grup Adı',
                        prefixIcon: Icon(Icons.group),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Grup adı boş olamaz' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _dersController,
                      decoration: const InputDecoration(
                        labelText: 'Ders / Konu',
                        prefixIcon: Icon(Icons.book),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ders boş olamaz' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _aciklamaController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Açıklama boş olamaz' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _konumController,
                      decoration: const InputDecoration(
                        labelText: 'Konum (ör: Kütüphane 2. Kat)',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Konum boş olamaz' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _maxKapasiteController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Maksimum Kapasite',
                        prefixIcon: Icon(Icons.people),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Kapasite giriniz';
                        if (int.tryParse(v) == null) return 'Geçerli sayı giriniz';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Grup Görseli (İsteğe Bağlı)',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _resimSec,
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _secilenResim != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _secilenResim!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Fotoğraf Seç',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      metin: 'Grubu Oluştur',
                      onPressed: _grubOlustur,
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        secilenIndex: 1,
        onTap: _navTap,
      ),
    );
  }

  void _navTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/duyurular');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profil');
        break;
    }
  }
}
