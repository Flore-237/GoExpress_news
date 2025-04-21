import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_express/Screens/AminSection/screens/reclamation_screen.dart';
import 'package:go_express/Screens/AminSection/screens/reservation_screen.dart';
import 'gestion_horaire_screen.dart';
import 'login_admin_screen.dart';
import 'support_client_screen.dart';

// Modèle pour les rôles utilisateur
class UserRole {
  static const String admin = 'admin';
  static const String client = 'client';
}

// Page principale admin
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  // Liste des pages administratives
  final List<Widget> _adminPages = [
    GestionHorairesScreen(),
    ReservationsScreen(),
    SupportClientScreen(),
    ReclamationsScreen(), // Fixed here
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return LoginAdminScreen(); // Rediriger vers la page de connexion
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard Agent de voyage'),
            backgroundColor: const Color(0xFF3D56F0),
          ),
          drawer: AdminDrawer(
            onPageSelected: (index) {
              setState(() {
                _selectedIndex = index; // Met à jour l'index sélectionné
                Navigator.pop(context); // Ferme le tiroir après la sélection
              });
            },
          ),
          body: _adminPages[_selectedIndex], // Affiche la page correspondante
        );
      },
    );
  }
}

class AdminDrawer extends StatelessWidget {
  final Function(int) onPageSelected;

  const AdminDrawer({required this.onPageSelected}); // Ajout de const pour une meilleure performance

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF3D56F0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu Agent de voyage',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text('Gestion des Horaires'),
            onTap: () => onPageSelected(0),
          ),
          ListTile(
            leading: Icon(Icons.book_online),
            title: Text('Réservations'),
            onTap: () => onPageSelected(1),
          ),
          ListTile(
            leading: Icon(Icons.support_agent),
            title: Text('Support Client'),
            onTap: () => onPageSelected(2),
          ),
          ListTile(
            leading: Icon(Icons.report_problem),
            title: Text('Réclamations'),
            onTap: () => onPageSelected(3),
          ),
        ],
      ),
    );
  }
}