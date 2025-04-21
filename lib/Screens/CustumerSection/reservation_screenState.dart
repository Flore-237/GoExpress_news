import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReservationScreen extends StatefulWidget {
  final String voyageId;
  final String agenceId;
  final String itineraireId;

  const ReservationScreen({
    Key? key,
    required this.voyageId,
    required this.agenceId,
    required this.itineraireId,
  }) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<Map<String, dynamic>> _voyageData;
  late Future<Map<String, dynamic>> _agenceData;
  late Future<Map<String, dynamic>> _itineraireData;

  // Contrôleurs pour les champs du formulaire
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _nombrePlacesController = TextEditingController(text: '1');
  String _typePlace = 'Classique';
  String? _numeroSiege;

  @override
  void initState() {
    super.initState();
    _voyageData = _fetchVoyageData();
    _agenceData = _fetchAgenceData();
    _itineraireData = _fetchItineraireData();
  }

  Future<Map<String, dynamic>> _fetchVoyageData() async {
    final doc = await FirebaseFirestore.instance
        .collection('voyages')
        .doc(widget.voyageId)
        .get();
    return doc.data() ?? {};
  }

  Future<Map<String, dynamic>> _fetchAgenceData() async {
    final doc = await FirebaseFirestore.instance
        .collection('agences')
        .doc(widget.agenceId)
        .get();
    return doc.data() ?? {};
  }

  Future<Map<String, dynamic>> _fetchItineraireData() async {
    final doc = await FirebaseFirestore.instance
        .collection('itineraires')
        .doc(widget.itineraireId)
        .get();
    return doc.data() ?? {};
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _nombrePlacesController.dispose();
    super.dispose();
  }

  Future<void> _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Créer la réservation dans Firestore
        await FirebaseFirestore.instance.collection('reservations').add({
          'voyageId': widget.voyageId,
          'agenceId': widget.agenceId,
          'itineraireId': widget.itineraireId,
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'email': _emailController.text,
          'telephone': _telephoneController.text,
          'nombrePlaces': int.parse(_nombrePlacesController.text),
          'typePlace': _typePlace,
          'numeroSiege': _numeroSiege,
          'dateReservation': DateTime.now(),
          'statut': 'confirmée',
          'prixTotal': await _calculateTotalPrice(),
        });

        // Mettre à jour le nombre de places disponibles
        await _updateAvailableSeats();

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation effectuée avec succès!'),
            backgroundColor: Colors.green,
          ),
        );

        // Retourner à l'écran précédent
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la réservation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<double> _calculateTotalPrice() async {
    final voyageData = await _voyageData;
    final nombrePlaces = int.parse(_nombrePlacesController.text);
    final prix = _typePlace == 'Classique'
        ? (voyageData['prixClassique'] as num?)?.toDouble() ?? 0
        : (voyageData['prixVIP'] as num?)?.toDouble() ?? 0;
    return prix * nombrePlaces;
  }

  Future<void> _updateAvailableSeats() async {
    final voyageRef = FirebaseFirestore.instance.collection('voyages').doc(widget.voyageId);
    final nombrePlaces = int.parse(_nombrePlacesController.text);

    if (_typePlace == 'Classique') {
      await voyageRef.update({
        'placesClassiqueDisponibles': FieldValue.increment(-nombrePlaces),
      });
    } else {
      await voyageRef.update({
        'placesVIPDisponibles': FieldValue.increment(-nombrePlaces),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservation'),
        backgroundColor: const Color(0xFF3D56F0),
      ),
      body: FutureBuilder(
        future: Future.wait([_voyageData, _agenceData, _itineraireData]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Erreur de chargement des données'));
          }

          final voyageData = snapshot.data![0] as Map<String, dynamic>;
          final agenceData = snapshot.data![1] as Map<String, dynamic>;
          final itineraireData = snapshot.data![2] as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations sur le voyage
                _buildVoyageInfoCard(voyageData, agenceData, itineraireData),
                const SizedBox(height: 24),

                // Formulaire de réservation
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations personnelles',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Nom
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Prénom
                      TextFormField(
                        controller: _prenomController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre prénom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Téléphone
                      TextFormField(
                        controller: _telephoneController,
                        decoration: const InputDecoration(
                          labelText: 'Téléphone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre numéro de téléphone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Détails de la réservation
                      const Text(
                        'Détails de la réservation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Type de place
                      DropdownButtonFormField<String>(
                        value: _typePlace,
                        decoration: const InputDecoration(
                          labelText: 'Type de place',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Classique', 'VIP']
                            .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _typePlace = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nombre de places
                      TextFormField(
                        controller: _nombrePlacesController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de places',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nombre de places';
                          }
                          final n = int.tryParse(value);
                          if (n == null || n <= 0) {
                            return 'Nombre invalide';
                          }

                          // Vérifier la disponibilité
                          final maxPlaces = _typePlace == 'Classique'
                              ? voyageData['placesClassiqueDisponibles'] as int?
                              : voyageData['placesVIPDisponibles'] as int?;
                          if (maxPlaces != null && n > maxPlaces) {
                            return 'Nombre de places indisponible';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Numéro de siège (optionnel)
                      TextFormField(
                        onChanged: (value) => _numeroSiege = value,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de siège (optionnel)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event_seat),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Bouton de réservation
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF3D56F0),
                          ),
                          onPressed: _submitReservation,
                          child: const Text(
                            'Confirmer la réservation',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoyageInfoCard(
      Map<String, dynamic> voyage, Map<String, dynamic> agence, Map<String, dynamic> itineraire) {
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final dateDepart = dateFormat.format(DateTime.parse(voyage['dateDepart']));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo de l'agence
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: agence['logo'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      agence['logo'].toString(),
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(Icons.business),
                ),
                const SizedBox(width: 12),
                Text(
                  agence['nom'] ?? 'Agence inconnue',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voyage['depart'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(voyage['heureDepart'] ?? '--:--'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${((itineraire['duree'] as num? ?? 0) / 60)
                          .toStringAsFixed(1)} h',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.blue),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      voyage['destination'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(voyage['heureArriveeEstimee'] ?? '--:--'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(dateDepart),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_bus, size: 16),
                const SizedBox(width: 8),
                Text('${voyage['typeBus'] ?? 'Bus standard'}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}