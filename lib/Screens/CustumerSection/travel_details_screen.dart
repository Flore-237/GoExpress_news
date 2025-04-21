import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ReservationScreen.dart';


class VoyageDetailsPage extends StatefulWidget {
  final String voyageId;
  final String agenceId;
  final String itineraireId;

  const VoyageDetailsPage({
    Key? key,
    required this.voyageId,
    required this.agenceId,
    required this.itineraireId,
  }) : super(key: key);

  @override
  _VoyageDetailsPageState createState() => _VoyageDetailsPageState();
}

class _VoyageDetailsPageState extends State<VoyageDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _voyage;
  Map<String, dynamic>? _agence;
  Map<String, dynamic>? _itineraire;
  List<Map<String, dynamic>> _avis = [];
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les détails du voyage
      DocumentSnapshot voyageSnapshot = await FirebaseFirestore.instance
          .collection('voyages')
          .doc(widget.voyageId)
          .get();

      if (!voyageSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ce voyage n\'existe plus')),
        );
        Navigator.pop(context);
        return;
      }

      // Charger les détails de l'agence
      DocumentSnapshot agenceSnapshot = await FirebaseFirestore.instance
          .collection('agences')
          .doc(widget.agenceId)
          .get();

      // Charger les détails de l'itinéraire
      DocumentSnapshot itineraireSnapshot = await FirebaseFirestore.instance
          .collection('itineraires')
          .doc(widget.itineraireId)
          .get();

      // Charger les avis pour cette agence
      QuerySnapshot avisSnapshot = await FirebaseFirestore.instance
          .collection('avis')
          .where('agenceId', isEqualTo: widget.agenceId)
          .orderBy('dateAvis', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> avis = [];
      for (var doc in avisSnapshot.docs) {
        var userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(doc['userId'])
            .get();

        avis.add({
          'id': doc.id,
          'note': doc['note'],
          'commentaire': doc['commentaire'],
          'dateAvis': doc['dateAvis'],
          'userName': userData['nom'] + ' ' + userData['prenom'],
          'userPhoto': userData['photo'],
        });
      }

      setState(() {
        _voyage = {
          'id': voyageSnapshot.id,
          ...voyageSnapshot.data() as Map<String, dynamic>,
        };

        _agence = {
          'id': agenceSnapshot.id,
          ...agenceSnapshot.data() as Map<String, dynamic>,
        };

        _itineraire = {
          'id': itineraireSnapshot.id,
          ...itineraireSnapshot.data() as Map<String, dynamic>,
        };

        _avis = avis;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des données : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement des données')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du voyage', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3D56F0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    // En-tête avec logo et informations de l'agence
    Container(
    color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _agence!['logo'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.business, size: 40),
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _agence!['nom'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(' ${_agence!['note'].toStringAsFixed(1)}'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_agence!['telephone']),
              ],
            ),
          ),
        ],
      ),
    ),

    // Détails du voyage
    Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Informations du voyage',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),

    // Trajet et horaires
    Card(
    elevation: 2,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text('Départ', style: TextStyle(color: Colors.grey)),
    Text(
    _voyage!['heureDepart'],
    style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    ),
    ),
    Text(_voyage!['dateDepart']),
    const SizedBox(height: 4),
    Text(_itineraire!['departure']),
    ],
    ),
    Column(
    children: [
    Text('${(_itineraire!['duree'] / 60).round()} h', style: const TextStyle(color: Colors.grey)),
    const Icon(Icons.arrow_forward),
    Text('${_itineraire!['distance']} km', style: const TextStyle(color: Colors.grey)),
    ],
    ),
    Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
    const Text('Arrivée', style: TextStyle(color: Colors.grey)),
    Text(
    _voyage!['heureArriveeEstimee'],
    style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    ),
    ),
    Text(_voyage!['dateArriveeEstimee']),
    const SizedBox(height: 4),
    Text(_itineraire!['destination']),
    ],
    ),
    ],
    ),
    ],
    ),
    ),
    ),

    const SizedBox(height: 16),

    // Informations de base du voyage
    Card(
    elevation: 2,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    children: [
    _infoRow('Numéro de voyage', _voyage!['numeroVoyage']),
    const Divider(),
    _infoRow('Statut', _voyage!['statut']),
    const Divider(),
    _infoRow('Chauffeur', _voyage!['chauffeur']),
    const Divider(),
    _infoRow('Immatriculation', _voyage!['immatriculation']),
    ],
    ),
    ),
    ),

    const SizedBox(height: 16),

    // Options de prix et disponibilité
    Card(
    elevation: 2,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Options et tarifs',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),

    // Option Classique
    Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    border: Border.all(color: Colors.grey[300]!),
    borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text(
    'Classique',
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    ),
    ),
    Text(
    '${_voyage!['prixClassique']} FCFA',
    style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    ),
    ),
    ],
    ),
    const SizedBox(height: 8),
    Text('Places disponibles: ${_voyage!['placesClassiqueDisponibles']}/${_voyage!['placesClassiqueTotal']}'),
    const SizedBox(height: 8),
    ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF3D56F0),
    minimumSize: const Size.fromHeight(40),
    ),
    onPressed: _voyage!['placesClassiqueDisponibles'] > 0
    ? () => _navigateToReservation('classique')
        : null,
    child: const Text('Réserver', style: TextStyle(color: Colors.white)),
    ),
    ],
    ),
    ),

    const SizedBox(height: 16),

    // Option VIP
    Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    border: Border.all(color: Colors.grey[300]!),
    borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text(
    'VIP',
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    ),
    ),
    Text(
    '${_voyage!['prixVIP']} FCFA',
    style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    ),
    ),
    ],
    ),
    const SizedBox(height: 8),
    Text('Places disponibles: ${_voyage!['placesVIPDisponibles']}/${_voyage!['placesVIPTotal']}'),
    const SizedBox(height: 8),
    ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF3D56F0),
    minimumSize: const Size.fromHeight(40),
    ),
    onPressed: _voyage!['placesVIPDisponibles'] > 0
    ? () => _navigateToReservation('VIP')
        : null,
    child: const Text('Réserver', style: TextStyle(color: Colors.white)),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),

    const SizedBox(height: 16),

    // Avis
    if (_avis.isNotEmpty) ...[
    const Text(
    'Avis des voyageurs',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
      const SizedBox(height: 8),
      Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              for (var avis in _avis) ...[
                _buildAvisItem(avis),
                if (avis != _avis.last)
                  const Divider(height: 16),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // Naviguer vers une page avec tous les avis
                  // Navigator.push(...);
                },
                child: const Text('Voir tous les avis'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],

      // Bouton de réservation
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D56F0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            // Par défaut, on propose la réservation classique si disponible
            if (_voyage!['placesClassiqueDisponibles'] > 0) {
              _navigateToReservation('classique');
            } else if (_voyage!['placesVIPDisponibles'] > 0) {
              _navigateToReservation('VIP');
            }
          },
          child: const Text(
            'Réserver maintenant',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const SizedBox(height: 32),
    ],
    ),
    ),
      ],
      ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAvisItem(Map<String, dynamic> avis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: avis['userPhoto'] != null
                  ? NetworkImage(avis['userPhoto'])
                  : null,
              child: avis['userPhoto'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avis['userName'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ...List.generate(5, (index) => Icon(
                      index < avis['note'] ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    )),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(
                        (avis['dateAvis'] as Timestamp).toDate(),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          avis['commentaire'],
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  void _navigateToReservation(String typePlace) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>ReservationScreen (
          voyageId: widget.voyageId,
          agenceId: widget.agenceId,
          typePlace: typePlace,
          prix: typePlace == 'VIP'
              ? _voyage!['prixVIP']
              : _voyage!['prixClassique'],
          departure: _itineraire!['departure'],
          destination: _itineraire!['destination'],
          dateDepart: _voyage!['dateDepart'],
          heureDepart: _voyage!['heureDepart'], userId: '',
        ),
      ),
    ).then((_) => _loadData()); // Rafraîchir les données après réservation
  }
}