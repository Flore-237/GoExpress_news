import 'package:flutter/material.dart';
import 'package:go_express/Screens/profile_page.dart';
import 'package:go_express/Screens/settings_page.dart';


class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return  Drawer(
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
            title: const Text('My account'),
            onTap: () {
              Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___)=>const ProfilePage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___)=>SettingsPage()));
            },
          ),ListTile(
            leading: const Icon(Icons.message),
            title: const Text('FAQ and Comment'),
            onTap: () {},
          ),ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {},
          ),ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Contact us'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
