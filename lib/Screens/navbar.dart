import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_express/Screens/CustumerSection/settings_page.dart';

import 'CustumerSection/profile_page.dart'; // Importez Firebase Auth

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF3D56F0),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Mon compte'),
            onTap: () {
              String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProfileWidget(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => SettingsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('FAQ et Commentaire'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Partager'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Contactez-nous'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Se connecter'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}