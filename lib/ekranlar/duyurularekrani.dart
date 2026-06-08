import 'package:flutter/material.dart';
import '../modeller/duyurumodeli.dart';
import '../servisler/firebaseservice.dart';
import '../servisler/sqliteservice.dart';
import '../widgetlar/global/customappbar.dart';
import '../widgetlar/global/custombottomnavbar.dart';

class DuyurularEkrani extends StatelessWidget {
  const DuyurularEkrani({super.key});

  void _duyuruEkleDialog(BuildContext context) {
    final baslikController = TextEditingController();
    final icerikController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool yukleniyor = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Yeni Duyuru',
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: baslikController,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Başlık boş olamaz' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: icerikController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Duyuru İçeriği',
                        prefixIcon: Icon(Icons.edit_note),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'İçerik boş olamaz' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: yukleniyor
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => yukleniyor = true);

                                final kullanici =
                                    await SqliteService().kullaniciGetir();
                                final yazar = kullanici != null
                                    ? kullanici.tamAd
                                    : 'Furkan Berk Usta';

                                final duyuru = DuyuruModeli(
                                  baslik: baslikController.text.trim(),
                                  icerik: icerikController.text.trim(),
                                  yazar: yazar,
                                  tarih: DateTime.now()
                                      .toLocal()
                                      .toString()
                                      .substring(0, 16),
                                );

                                await FirebaseService().duyuruEkle(duyuru);
                                setModalState(() => yukleniyor = false);

                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Duyuru yayınlandı!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                        icon: yukleniyor
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send),
                        label: Text(yukleniyor ? 'Yayınlanıyor...' : 'Yayınla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(ctx).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: StreamBuilder<List<DuyuruModeli>>(
        stream: FirebaseService().duyurulariGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final duyurular = snapshot.data ?? [];

          if (duyurular.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz duyuru yok.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'İlk duyuruyu yayınlamak için + butonuna tıkla!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            itemCount: duyurular.length,
            itemBuilder: (context, index) {
              final duyuru = duyurular[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.campaign,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  duyuru.baslik,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.person_outline,
                                        size: 13,
                                        color: Colors.grey.shade500),
                                    const SizedBox(width: 3),
                                    Text(
                                      duyuru.yazar,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(Icons.access_time,
                                        size: 13,
                                        color: Colors.grey.shade500),
                                    const SizedBox(width: 3),
                                    Text(
                                      duyuru.tarih,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Text(
                        duyuru.icerik,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _duyuruEkleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Duyuru Yap'),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        secilenIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/grup-olustur');
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profil');
              break;
          }
        },
      ),
    );
  }
}
