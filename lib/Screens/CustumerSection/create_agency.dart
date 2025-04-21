import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateAgencyScreen extends StatefulWidget {
  @override
  _CreateAgencyScreenState createState() => _CreateAgencyScreenState();
}

class _CreateAgencyScreenState extends State<CreateAgencyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Variables pour stocker les données du formulaire
  String _agencyName = "";
  List<String> _departure = [];
  List<String> _destination = [];
  String _seats = "";
  String _imageUrl = "";
  List<String> _departureTimes = [];
  List<String> _departureDates = [];
  List<String> _seatTypes = [];

  // Contrôleurs pour les champs de texte
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _departureTimeController = TextEditingController();
  final TextEditingController _seatTypeController = TextEditingController();

  // Fonction pour ajouter une agence dans Firestore
  Future<void> _createAgency() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Générer les dates de départ de mars à juillet
      _departureDates = _generateDepartureDates();

      // Ajouter l'agence à Firestore
      await _firestore.collection('agences').add({
        'agencyName': _agencyName,
        'departure': _departure,
        'destination': _destination,
        'seats': _seats,
        'imageUrl': _imageUrl,
        'departureTime': _departureTimes,
        'departureDate': _departureDates,
        'seatType': _seatTypes,
      });

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agence créée avec succès !')),
      );

      // Réinitialiser le formulaire
      _formKey.currentState!.reset();
      _departure.clear();
      _destination.clear();
      _departureTimes.clear();
      _seatTypes.clear();
    }
  }

  // Générer les dates de départ de mars à juillet 
  List<String> _generateDepartureDates() {
    List<String> dates = [];
    for (int month = 3; month <= 7; month++) {
      for (int day = 1; day <= 31; day++) {
        try {
          DateTime date = DateTime(2023, month, day);
          dates.add("${_getDayName(date.weekday)}, ${day.toString().padLeft(2, '0')} ${_getMonthName(month)}");
        } catch (e) {
          // Ignorer les dates invalides
        }
      }
    }
    return dates;
  }

  // Convertir le jour de la semaine en nom
  String _getDayName(int day) {
    switch (day) {
      case 1: return "Lundi";
      case 2: return "Mardi";
      case 3: return "Mercredi";
      case 4: return "Jeudi";
      case 5: return "Vendredi";
      case 6: return "Samedi";
      case 7: return "Dimanche";
      default: return "";
    }
  }

  // Convertir le mois en nom
  String _getMonthName(int month) {
    switch (month) {
      case 1: return "Janvier";
      case 2: return "Février";
      case 3: return "Mars";
      case 4: return "Avril";
      case 5: return "Mai";
      case 6: return "Juin";
      case 7: return "Juillet";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une Agence', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champ pour le nom de l'agence
              _buildTextField(
                label: 'Nom de l\'agence',
                onSaved: (value) => _agencyName = value!,
                validator: (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null,
              ),
              SizedBox(height: 20),

              // Champ pour les lieux de départ
              _buildMultiInputField(
                label: 'Lieux de départ',
                controller: _departureController,
                onAdd: () {
                  if (_departureController.text.isNotEmpty) {
                    setState(() {
                      _departure.add(_departureController.text);
                      _departureController.clear();
                    });
                  }
                },
                items: _departure,
              ),
              SizedBox(height: 20),

              // Champ pour les destinations
              _buildMultiInputField(
                label: 'Destinations',
                controller: _destinationController,
                onAdd: () {
                  if (_destinationController.text.isNotEmpty) {
                    setState(() {
                      _destination.add(_destinationController.text);
                      _destinationController.clear();
                    });
                  }
                },
                items: _destination,
              ),
              SizedBox(height: 20),

              // Champ pour le nombre de sièges
              _buildTextField(
                label: 'Nombre de sièges',
                onSaved: (value) => _seats = value!,
                validator: (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),

              // Champ pour l'URL de l'imagen,';

              _buildTextField(
                label: 'URL de l\'image',
                onSaved: (value) => _imageUrl = value!,
                validator: (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null,
              ),
              SizedBox(height: 20),

              // Champ pour les heures de départ//
              _buildMultiInputField(
                label: 'Heures de départ',
                controller: _departureTimeController,
                onAdd: () {
                  if (_departureTimeController.text.isNotEmpty) {
                    setState(() {
                      _departureTimes.add(_departureTimeController.text);
                      _departureTimeController.clear();
                    });
                  }
                },
                items: _departureTimes,
              ),
              SizedBox(height: 20),

              // Champ pour les types de sièges  un  deux
              _buildMultiInputField(
                label: 'Types de sièges',
                controller: _seatTypeController,
                onAdd: () {
                  if (_seatTypeController.text.isNotEmpty) {
                    setState(() {
                      _seatTypes.add(_seatTypeController.text);
                      _seatTypeController.clear();
                    });
                  }
                },
                items: _seatTypes,
              ),
              SizedBox(height: 30),

              // Bouton pour créer l'agence
              Center(
                child: ElevatedButton(
                  onPressed: _createAgency,
                  child: Text('Créer l\'agence', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour créer un champ de texte
  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  // Widget pour créer un champ avec plusieurs entrées
  Widget _buildMultiInputField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.add, color: Colors.blueAccent),
              onPressed: onAdd,
            ),
          ],
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: items.map((item) => Chip(
            label: Text(item),
            backgroundColor: Colors.blueAccent.withOpacity(0.2),
            deleteIcon: Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                items.remove(item);
              });
            },
          )).toList(),
        ),
      ],
    );
  }
}