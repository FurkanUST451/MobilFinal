import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../modeller/kullanicimodeli.dart';
import '../servisler/sqliteservice.dart';
import '../servisler/supabaseservice.dart';
import '../widgetlar/components/custombutton.dart';
import '../widgetlar/global/customappbar.dart';
import '../widgetlar/global/custombottomnavbar.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _emailController = TextEditingController();
  String _fotoUrl = '';
  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    _kullaniciyiYukle();
  }

  Future<void> _kullaniciyiYukle() async {
    final kullanici = await SqliteService().kullaniciGetir();
    if (kullanici == null) {
      _adController.text = 'Furkan Berk';
      _soyadController.text = 'Usta';
      _emailController.text = '030722042@std.izu.edu.tr';
    } else {
      _adController.text = kullanici.ad;
      _soyadController.text = kullanici.soyad;
      _emailController.text = kullanici.email;
      setState(() => _fotoUrl = kullanici.fotoUrl);
    }
  }

  Future<void> _fotoSec() async {
    final picker = ImagePicker();
    final secilen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (secilen == null) return;

    setState(() => _yukleniyor = true);
    try {
      final url = await SupabaseService().profilFotosuYukle(File(secilen.path));
      await SqliteService().fotoUrlGuncelle(url);
      setState(() => _fotoUrl = url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı güncellendi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      setState(() => _yukleniyor = false);
    }
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;

    final kullanici = KullaniciModeli(
      id: 1,
      ad: _adController.text.trim(),
      soyad: _soyadController.text.trim(),
      email: _emailController.text.trim(),
      fotoUrl: _fotoUrl,
    );
    await SqliteService().kullaniciyiKaydet(kullanici);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil kaydedildi!')),
      );
    }
  }

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
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
                  children: [
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: _fotoUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: _fotoUrl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _fotoSec,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _adController,
                      decoration: const InputDecoration(
                        labelText: 'Ad',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ad boş olamaz' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _soyadController,
                      decoration: const InputDecoration(
                        labelText: 'Soyad',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Soyad boş olamaz' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'E-posta boş olamaz' : null,
                    ),
                    const SizedBox(height: 30),
                    CustomButton(metin: 'Kaydet', onPressed: _kaydet),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        secilenIndex: 3,
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
        Navigator.pushReplacementNamed(context, '/grup-olustur');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/duyurular');
        break;
      case 3:
        break;
    }
  }
}
