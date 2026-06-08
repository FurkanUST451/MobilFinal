import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ekranlar/anaekran.dart';
import 'ekranlar/detayekrani.dart';
import 'ekranlar/grupolusturekrani.dart';
import 'ekranlar/profilekrani.dart';
import 'servisler/temaprovider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Supabase.initialize(
    url: 'https://gbyqfwlschuojpdlvyzj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdieXFmd2xzY2h1b2pwZGx2eXpqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA5Mjk0NzAsImV4cCI6MjA5NjUwNTQ3MH0.JnmhEuk7ERvpAOzKUnQiKusMYb8xPUWmjp3kYY9j5Xo',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => TemaProvider()..temaYukle(),
      child: const CampusConnectApp(),
    ),
  );
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TemaProvider>(
      builder: (context, temaProvider, _) {
        return MaterialApp(
          title: 'SosyalÇalışmaGrupları',
          debugShowCheckedModeBanner: false,
          themeMode: temaProvider.temaMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const AnaEkran(),
            '/detay': (context) => const DetayEkrani(),
            '/grup-olustur': (context) => const GrupOlusturEkrani(),
            '/profil': (context) => const ProfilEkrani(),
          },
        );
      },
    );
  }
}
