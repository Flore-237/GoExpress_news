import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_express/Screens/CustumerSection/profile_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../presentation/AdminDashbord_screen.dart';
import '../../presentation/editAgence_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _dateAllerController = TextEditingController();
  final TextEditingController _heureAllerController = TextEditingController();
  String? _selectedDeparture;
  String? _selectedDestination;
  List<String> _departures = [];
  List<String> _destinations = [];
  List<String> _agencies = [];
  List<Map<String, dynamic>> _agencyDetails = [];
  bool _isLoading = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _checkConnectivityAndLoadData();
    _checkAdminStatus();
  }

  Future<void> _checkConnectivityAndLoadData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pas de connexion Internet')),
        );
      }
      return;
    }
    _fetchLocations();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (mounted) {
          setState(() {
            _isAdmin = userDoc.data()?['isAdmin'] ?? false;
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut admin: $e');
    }
  }

  Future<void> _fetchLocations() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      CollectionReference locations = FirebaseFirestore.instance.collection('TravelInfo');
      QuerySnapshot snapshot = await locations.get();

      if (mounted) {
        setState(() {
          _departures = snapshot.docs.map((doc) => doc['departure'] as String).toSet().toList();
          _destinations = snapshot.docs.map((doc) => doc['destination'] as String).toSet().toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des données: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchAgencies() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      CollectionReference agencies = FirebaseFirestore.instance.collection('agences');
      QuerySnapshot snapshot = await agencies.get();

      if (mounted) {
        setState(() {
          _agencies = snapshot.docs.map((doc) => doc['agencyName'] as String).toSet().toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des agences: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchAgencyDetails(String agencyName) async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      CollectionReference travelInfo = FirebaseFirestore.instance.collection('agences');
      QuerySnapshot snapshot = await travelInfo.where('agencyName', isEqualTo: agencyName).get();

      if (mounted) {
        setState(() {
          _agencyDetails = snapshot.docs.map((doc) {
            return {
              'departure': doc['departure'],
              'destination': doc['destination'],
              'time': doc['departureTime'].join(', '),
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des détails: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectLocation(BuildContext context, List<String> locations, Function(String) onSelected) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionnez un point'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: locations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(locations[index]),
                  onTap: () {
                    onSelected(locations[index]);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = "${picked.toLocal()}".split(' ')[0]; // Format YYYY-MM-DD
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bienvenue',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3D56F0),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
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
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                if (userId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileWidget(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez vous connecter pour accéder au profil')),
                  );
                }
              },
            ),
            if (_isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
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
                leading: const Icon(Icons.add_business),
                title: const Text('Créer Agence'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditAgencyScreen(agencyId: '',)),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(
                      color: const Color(0xFF3D56F0),
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(color: Colors.transparent),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/busFondBon.jpeg'),
                                  fit: BoxFit.cover,
                                  onError: null,
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14.0),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Où allons-nous aujourd\'hui ?',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              const Text('Point de départ', style: TextStyle(fontSize: 16)),
                              GestureDetector(
                                onTap: () => _selectLocation(context, _departures, (selected) {
                                  setState(() {
                                    _selectedDeparture = selected;
                                  });
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_selectedDeparture ?? 'Sélectionnez un point de départ'),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              const Text('Destination', style: TextStyle(fontSize: 16)),
                              GestureDetector(
                                onTap: () => _selectLocation(context, _destinations, (selected) {
                                  setState(() {
                                    _selectedDestination = selected;
                                  });
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_selectedDestination ?? 'Sélectionnez une destination'),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectDate(context, _dateAllerController),
                                      child: AbsorbPointer(
                                        child: TextFormField(
                                          controller: _dateAllerController,
                                          decoration: InputDecoration(
                                            labelText: 'Date de départ',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectTime(context, _heureAllerController),
                                      child: AbsorbPointer(
                                        child: TextFormField(
                                          controller: _heureAllerController,
                                          decoration: InputDecoration(
                                            labelText: 'Heure de départ',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () {
                                  if (_selectedDeparture == null || _selectedDestination == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Veuillez sélectionner tous les champs obligatoires')),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchResultsScreen(
                                          departure: _selectedDeparture!,
                                          destination: _selectedDestination!,
                                          dateAller: _dateAllerController.text.isNotEmpty ? _dateAllerController.text : null,
                                          heureAller: _heureAllerController.text.isNotEmpty ? _heureAllerController.text : null,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3D56F0),
                                  minimumSize: const Size.fromHeight(40.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'RECHERCHER',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () async {
                                  await _fetchAgencies(); // Récupérer les agences
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Choisir une agence'),
                                        content: SizedBox(
                                          width: 300,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: _agencies.length,
                                            itemBuilder: (context, index) {
                                              return Card(
                                                margin: const EdgeInsets.symmetric(vertical: 8),
                                                child: ListTile(
                                                  title: Text(_agencies[index]),
                                                  trailing: const Icon(Icons.arrow_forward),
                                                  onTap: () {
                                                    _fetchAgencyDetails(_agencies[index]);
                                                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                                                    _showAgencyDetails(context); // Afficher les détails de l'agence
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3D56F0),
                                  minimumSize: const Size.fromHeight(40.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Choisir une agence',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showAgencyDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Horaires et Destinations'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _agencyDetails.length,
              itemBuilder: (context, index) {
                final agencyDetail = _agencyDetails[index];
                return ListTile(
                  title: Text('${agencyDetail['departure']} → ${agencyDetail['destination']}'),
                  subtitle: Text('Heure: ${agencyDetail['time']}'), // Afficher l'heure
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}