import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int secilenIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.secilenIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: secilenIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Gruplar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Oluştur',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign_outlined),
          label: 'Duyurular',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
