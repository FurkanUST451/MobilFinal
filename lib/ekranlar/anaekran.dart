import 'package:flutter/material.dart';
import '../modeller/calismagurubumodeli.dart';
import '../servisler/firebaseservice.dart';
import '../widgetlar/components/customcard.dart';
import '../widgetlar/global/customappbar.dart';
import '../widgetlar/global/customappdrawer.dart';
import '../widgetlar/global/custombottomnavbar.dart';

class AnaEkran extends StatelessWidget {
  const AnaEkran({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomAppDrawer(),
      body: StreamBuilder<List<CalismaGrubuModeli>>(
        stream: FirebaseService().gruplariGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}'),
            );
          }

          final gruplar = snapshot.data ?? [];

          if (gruplar.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz çalışma grubu yok.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'İlk grubu oluşturmak için + butonuna tıkla!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: gruplar.length,
            itemBuilder: (context, index) {
              final grup = gruplar[index];
              return CustomCard(
                grup: grup,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/detay',
                    arguments: grup,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/grup-olustur'),
        icon: const Icon(Icons.add),
        label: const Text('Grup Oluştur'),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        secilenIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushReplacementNamed(context, '/grup-olustur');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/duyurular');
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
