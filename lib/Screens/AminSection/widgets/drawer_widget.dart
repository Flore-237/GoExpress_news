import 'package:flutter/material.dart';
import 'package:go_express/Screens/CustumerSection/profile_page.dart';
import '../../CustumerSection/create_agency.dart';
import '../screens/agent_home_screen.dart';


Widget buildAppDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Color(0xFF3D56F0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Menu GoExpress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Votre compagnon de voyage',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home, color: Color(0xFF3D56F0)),
          title: const Text('Accueil'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.person, color: Color(0xFF3D56F0)),
          title: const Text('Profil'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileWidget(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF3D56F0)),
          title: const Text('Admin'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.add_business, color: Color(0xFF3D56F0)),
          title: const Text('Créer Agence'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateAgencyScreen()),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help_outline, color: Color(0xFF3D56F0)),
          title: const Text('Aide'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}