import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../modeller/calismagurubumodeli.dart';
import '../servisler/firebaseservice.dart';
import '../servisler/sqliteservice.dart';
import '../widgetlar/global/customappbar.dart';

class DetayEkrani extends StatefulWidget {
  const DetayEkrani({super.key});

  @override
  State<DetayEkrani> createState() => _DetayEkraniState();
}

class _DetayEkraniState extends State<DetayEkrani> {
  CalismaGrubuModeli? _grup;
  bool _islem = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _grup = ModalRoute.of(context)?.settings.arguments as CalismaGrubuModeli?;
  }

  Future<void> _grubaKatil() async {
    if (_grup == null) return;
    setState(() => _islem = true);

    try {
      final kullanici = await SqliteService().kullaniciGetir();
      final katilimci = kullanici != null ? kullanici.tamAd : 'Furkan Berk Usta';

      if (_grup!.katilimcilar.contains(katilimci)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zaten bu gruba katıldınız.')),
          );
        }
        return;
      }

      if (_grup!.katilimcilar.length >= _grup!.maxKapasite) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grup kapasitesi dolu!')),
          );
        }
        return;
      }

      await FirebaseService().grubaKatil(_grup!.id!, katilimci);

      setState(() {
        _grup = CalismaGrubuModeli(
          id: _grup!.id,
          ad: _grup!.ad,
          ders: _grup!.ders,
          aciklama: _grup!.aciklama,
          olusturan: _grup!.olusturan,
          katilimcilar: [..._grup!.katilimcilar, katilimci],
          tarih: _grup!.tarih,
          konum: _grup!.konum,
          maxKapasite: _grup!.maxKapasite,
          gorselUrl: _grup!.gorselUrl,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gruba başarıyla katıldınız!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      setState(() => _islem = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_grup == null) {
      return const Scaffold(body: Center(child: Text('Grup bulunamadı.')));
    }

    final dolulukOrani = _grup!.maxKapasite > 0
        ? (_grup!.katilimcilar.length / _grup!.maxKapasite).clamp(0.0, 1.0)
        : 0.0;
    final dolu = _grup!.katilimcilar.length >= _grup!.maxKapasite;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Görsel ---
            SizedBox(
              height: 240,
              width: double.infinity,
              child: _grup!.gorselUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _grup!.gorselUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => _gorselPlaceholder(),
                    )
                  : _gorselPlaceholder(),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Başlık + Ders ---
                  Text(
                    _grup!.ad,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book, size: 15,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 5),
                        Text(
                          _grup!.ders,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Bilgi Kartları ---
                  _bilgiKarti(
                    context,
                    icon: Icons.description_outlined,
                    baslik: 'Açıklama',
                    deger: _grup!.aciklama,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _bilgiKutusu(
                          context,
                          icon: Icons.person_outline,
                          baslik: 'Oluşturan',
                          deger: _grup!.olusturan,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _bilgiKutusu(
                          context,
                          icon: Icons.calendar_today_outlined,
                          baslik: 'Tarih',
                          deger: _grup!.tarih,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _bilgiKutusu(
                    context,
                    icon: Icons.location_on_outlined,
                    baslik: 'Konum',
                    deger: _grup!.konum,
                  ),

                  const SizedBox(height: 20),

                  // --- Kapasite ---
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people_outline, size: 18),
                                const SizedBox(width: 6),
                                const Text('Kapasite',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Text(
                              '${_grup!.katilimcilar.length} / ${_grup!.maxKapasite} kişi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: dolu ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: dolulukOrani,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            color: dolu ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Katılımcılar ---
                  if (_grup!.katilimcilar.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Katılımcılar',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _grup!.katilimcilar.map((k) {
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              k.isNotEmpty ? k[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          label: Text(k, style: const TextStyle(fontSize: 13)),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // --- Katıl Butonu ---
                  _islem
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: dolu ? null : _grubaKatil,
                            icon: Icon(
                                dolu ? Icons.block : Icons.group_add_outlined),
                            label: Text(
                              dolu ? 'Grup Dolu' : 'Gruba Katıl',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dolu
                                  ? Colors.grey
                                  : theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gorselPlaceholder() {
    return Container(
      color: Colors.blue.shade50,
      child: Center(
        child: Icon(Icons.group, size: 80, color: Colors.blue.shade200),
      ),
    );
  }

  Widget _bilgiKarti(BuildContext context,
      {required IconData icon,
      required String baslik,
      required String deger}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(baslik,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Text(deger, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _bilgiKutusu(BuildContext context,
      {required IconData icon,
      required String baslik,
      required String deger}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: theme.colorScheme.primary),
              const SizedBox(width: 5),
              Text(baslik,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 5),
          Text(deger,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 2),
        ],
      ),
    );
  }
}
