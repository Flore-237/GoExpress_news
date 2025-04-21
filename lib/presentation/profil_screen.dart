import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/service/notification_service.dart';


class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  // Mock data for testing
  factory UserProfile.mock() {
    return UserProfile(
      id: 'user123',
      name: 'Jean Dupont',
      email: 'jean.dupont@example.com',
      phone: '678901234',
      profileImage: null,
    );
  }
}

class ProfileProvider extends ChangeNotifier {
  UserProfile _userProfile = UserProfile.mock();

  UserProfile get userProfile => _userProfile;

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    _userProfile = UserProfile(
      id: _userProfile.id,
      name: name ?? _userProfile.name,
      email: email ?? _userProfile.email,
      phone: phone ?? _userProfile.phone,
      profileImage: profileImage ?? _userProfile.profileImage,
    );

    notifyListeners();
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = Provider.of<ProfileProvider>(context, listen: false).userProfile;
      _nameController = TextEditingController(text: profile.name);
      _emailController = TextEditingController(text: profile.email);
      _phoneController = TextEditingController(text: profile.phone);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.userProfile;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon Profil'),
            backgroundColor: Colors.blue[900],
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      // Cancel editing
                      _nameController.text = profile.name;
                      _emailController.text = profile.email;
                      _phoneController.text = profile.phone;
                    }
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Profile Image
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: profile.profileImage != null
                            ? NetworkImage(profile.profileImage!)
                            : null,
                        child: profile.profileImage == null
                            ? Text(
                          profile.name.isNotEmpty
                              ? profile.name.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        )
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.blue[900],
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              onPressed: () {
                                // Implémentation pour changer la photo de profil
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fonctionnalité à implémenter'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Profile Information or Edit Form
                  _isEditing ? _buildEditForm() : _buildProfileInfo(profile),

                  const SizedBox(height: 30),

                  // Additional sections
                  if (!_isEditing) ...[
                    _buildSection(
                      title: 'Mes Réservations',
                      icon: Icons.confirmation_number,
                      onTap: () {
                        Navigator.pushNamed(context, '/my-reservations');
                      },
                    ),

                    _buildSection(
                      title: 'Mes Paiements',
                      icon: Icons.payment,
                      onTap: () {
                        Navigator.pushNamed(context, '/my-payments');
                      },
                    ),

                    _buildSection(
                      title: 'Paramètres de Notification',
                      icon: Icons.notifications,
                      onTap: () {
                        Navigator.pushNamed(context, '/notification-settings');
                      },
                    ),

                    _buildSection(
                      title: 'Aide et Support',
                      icon: Icons.help,
                      onTap: () {
                        Navigator.pushNamed(context, '/help-support');
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle logout
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Déconnexion...'),
                            ),
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pushReplacementNamed(context, '/login');
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileInfo(UserProfile profile) {
    return Column(
      children: [
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),

        // Email
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                profile.email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Phone
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '+237 ${profile.phone}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),
        const Divider(),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            'Modifier votre profil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Email field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!value.contains('@')) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Phone field
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro de téléphone';
              }
              if (value.length != 9) {
                return 'Le numéro doit contenir 9 chiffres';
              }
              return null;
            },
          ),
          const SizedBox(height: 25),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await Provider.of<ProfileProvider>(context, listen: false)
                        .updateProfile(
                      name: _nameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                    );

                   /* if (!mounted) return;

                    Provider.of<NotificationService>(context, listen: false)
                        .showNotification(
                      title: 'Profil mis à jour',
                      body: 'Vos informations ont été mises à jour avec succès.',
                    );*/

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil mis à jour avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    setState(() {
                      _isEditing = false;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text(
                'Enregistrer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.blue[900]),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}