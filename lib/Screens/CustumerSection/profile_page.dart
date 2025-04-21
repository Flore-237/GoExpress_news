import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../AminSection/screens/reclamation_screen.dart';
import '../AminSection/screens/support_client_screen.dart';

class ProfileWidget extends StatefulWidget {
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  String name = '';
  String email = '';
  String phoneNumber = '';
  String userID = '';
  String profileImageUrl = '';
  bool isLoading = true;
  File? _imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        userID = user.uid;
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userID).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            name = userData['name'] ?? 'Utilisateur';
            email = userData['email'] ?? '';
            phoneNumber = userData['phoneNumber'] ?? '';
            profileImageUrl = userData['profileImageUrl'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    try {
      String fileName = path.basename(_imageFile!.path);
      Reference storageRef = _storage.ref().child('profile_images/$userID/$fileName');

      await storageRef.putFile(_imageFile!);
      String downloadUrl = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(userID).update({
        'profileImageUrl': downloadUrl
      });

      setState(() {
        profileImageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo de profil mise à jour avec succès'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour de la photo: $e'))
      );
    }
  }

  Future<void> _updateUserInfo(String field, String value) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        field: value
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Information mise à jour avec succès'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e'))
      );
    }
  }

  void _showEditDialog(String field, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${field == 'name' ? 'nom' : field == 'email' ? 'email' : 'numéro de téléphone'}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
              hintText: 'Entrez votre ${field == 'name' ? 'nom' : field == 'email' ? 'email' : 'numéro de téléphone'}'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _updateUserInfo(field, controller.text);
              setState(() {
                if (field == 'name') name = controller.text;
                if (field == 'email') email = controller.text;
                if (field == 'phoneNumber') phoneNumber = controller.text;
              });
              Navigator.pop(context);
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(String page) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) {
            switch (page) {
              case 'history':
                return HistoryPage();
              case 'payment':
                return PaymentNumberPage();
              case 'tickets':
                return TicketsPage();
              case 'support':
                return SupportClientScreen();
              case 'claims':
                return ReclamationsScreen();
              default:
                return ProfileWidget();
            }
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        backgroundColor: Color(0xFF3D56F0),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF3D56F0)))
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: Color(0xFF3D56F0),
              width: double.infinity,
              height: 220,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl) as ImageProvider
                              : null),
                          child: (_imageFile == null && profileImageUrl.isEmpty)
                              ? Icon(Icons.person, size: 50, color: Color(0xFF3D56F0))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Color(0xFF3D56F0), width: 2)
                            ),
                            child: Icon(Icons.camera_alt, size: 20, color: Color(0xFF3D56F0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Bonjour, $name",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    )
                  ]
              ),
              child: Column(
                children: [
                  MenuItemWidget(
                    icon: Icons.history,
                    title: "Historique",
                    onTap: () => _navigateToPage('history'),
                  ),
                  Divider(height: 1),
                  MenuItemWidget(
                    icon: Icons.account_balance,
                    title: "Numéro payeur",
                    onTap: () => _navigateToPage('payment'),
                  ),
                  Divider(height: 1),
                  MenuItemWidget(
                    icon: Icons.airplane_ticket,
                    title: "Mes billets / Réservations",
                    onTap: () => _navigateToPage('tickets'),
                  ),
                  Divider(height: 1),
                  MenuItemWidget(
                    icon: Icons.support_agent,
                    title: "Support client",
                    onTap: () => _navigateToPage('support'),
                  ),
                  Divider(height: 1),
                  MenuItemWidget(
                    icon: Icons.report_problem,
                    title: "Réclamations",
                    onTap: () => _navigateToPage('claims'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Informations de l'utilisateur"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFF3D56F0)),
              title: Text("Nom"),
              subtitle: Text(name),
              trailing: Icon(Icons.edit, color: Color(0xFF3D56F0)),
              onTap: () => _showEditDialog('name', name),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email, color: Color(0xFF3D56F0)),
              title: Text("Email"),
              subtitle: Text(email),
              trailing: Icon(Icons.edit, color: Color(0xFF3D56F0)),
              onTap: () => _showEditDialog('email', email),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.phone, color: Color(0xFF3D56F0)),
              title: Text("Téléphone"),
              subtitle: Text(phoneNumber.isNotEmpty ? phoneNumber : "Non renseigné"),
              trailing: Icon(Icons.edit, color: Color(0xFF3D56F0)),
              onTap: () => _showEditDialog('phoneNumber', phoneNumber),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MenuItemWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF3D56F0), size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historique"),
        backgroundColor: Color(0xFF3D56F0),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('history')
            .orderBy('date', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur lors du chargement de l'historique"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Aucun historique disponible",
                      style: TextStyle(fontSize: 18, color: Colors.grey)
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF3D56F0),
                    child: Icon(Icons.flight, color: Colors.white),
                  ),
                  title: Text(data['title'] ?? 'Activité',
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(data['description'] ?? 'Aucune description'),
                      SizedBox(height: 4),
                      Text(
                        data['date'] != null
                            ? data['date'].toDate().toString().substring(0, 16)
                            : 'Date inconnue',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PaymentNumberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Numéro payeur"),
        backgroundColor: Color(0xFF3D56F0),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur lors du chargement des données"));
          }

          var userData = snapshot.data?.data() as Map<String, dynamic>?;
          String paymentNumber = userData?['paymentNumber'] ?? 'Non enregistré';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3D56F0), Color(0xFF5E73FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        )
                      ]
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.credit_card, color: Colors.white, size: 50),
                      SizedBox(height: 20),
                      Text(
                        "Numéro payeur",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        paymentNumber,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                if (paymentNumber == 'Non enregistré')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3D56F0),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      TextEditingController controller = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Ajouter un numéro payeur'),
                          content: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                                hintText: 'Entrez votre numéro payeur'
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser?.uid)
                                    .update({
                                  'paymentNumber': controller.text
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Numéro payeur enregistré avec succès'))
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => PaymentNumberPage()),
                                );
                              },
                              child: Text('Enregistrer'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      "Ajouter un numéro payeur",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
class TicketsPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: Text("Mes billets / Réservations"),
    backgroundColor: Color(0xFF3D56F0),
    ),
    body: FutureBuilder<QuerySnapshot>(
    future: FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('tickets')
        .orderBy('date', descending: true)
        .get(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
    return Center(child: Text("Erreur lors du chargement des billets"));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.airplane_ticket, size: 80, color: Colors.grey),
    SizedBox(height: 16),
    Text("Aucun billet ou réservation disponible",
    style: TextStyle(fontSize: 18, color: Colors.grey)),
    ],
    ),
    );
    }

    return ListView.builder(
    padding: EdgeInsets.all(16),
    itemCount: snapshot.data!.docs.length,
    itemBuilder: (context, index) {
    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
    return Card(
    margin: EdgeInsets.only(bottom: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
    contentPadding: EdgeInsets.all(16),
    leading: CircleAvatar(
    backgroundColor: Color(0xFF3D56F0),
    child: Icon(Icons.airplane_ticket, color: Colors.white),
    ),
    title: Text(data['title'] ?? 'Billet',
    style: TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    SizedBox(height: 4),
    Text(data['description'] ?? 'Aucune description'),
    SizedBox(height: 4),
    Text(
    data['date'] != null
    ? data['date'].toDate().toString().substring(0, 16)
        : 'Date inconnue',
    style: TextStyle(color: Colors.grey),
    ),
    ],
    ),
    ),
    );
    },
    );
    },
    ),
    );
    }
    }