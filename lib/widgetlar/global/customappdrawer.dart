import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modeller/kullanicimodeli.dart';
import '../../servisler/sqliteservice.dart';
import '../../servisler/temaprovider.dart';

class CustomAppDrawer extends StatefulWidget {
  const CustomAppDrawer({super.key});

  @override
  State<CustomAppDrawer> createState() => _CustomAppDrawerState();
}

class _CustomAppDrawerState extends State<CustomAppDrawer> {
  KullaniciModeli? _kullanici;

  @override
  void initState() {
    super.initState();
    _kullaniciyiYukle();
  }

  Future<void> _kullaniciyiYukle() async {
    final kullanici = await SqliteService().kullaniciGetir();
    if (mounted) setState(() => _kullanici = kullanici);
  }

  @override
  Widget build(BuildContext context) {
    final temaProvider = Provider.of<TemaProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: _kullanici != null && _kullanici!.fotoUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _kullanici!.fotoUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _kullanici?.tamAd ?? 'Furkan Berk Usta',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _kullanici?.email ?? '030722042@std.izu.edu.tr',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Karanlık Mod'),
            secondary: const Icon(Icons.dark_mode),
            value: temaProvider.karanlik,
            onChanged: (deger) {
              temaProvider.temaDegistir(deger);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil Düzenle'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profil').then((_) {
                _kullaniciyiYukle();
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Çalışma Grupları'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: const Text('Duyurular'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/duyurular');
            },
          ),
        ],
      ),
    );
  }
}
