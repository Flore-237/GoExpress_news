import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/horaire.dart';
import '../services/horaire_service.dart';

class GestionHorairesScreen extends StatefulWidget {
  static const routeName = '/goExpress';

  @override
  _GestionHorairesScreenState createState() => _GestionHorairesScreenState();
}

class _GestionHorairesScreenState extends State<GestionHorairesScreen> {
  final HoraireService _horaireService = HoraireService();

  void _addHoraire() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: HoraireFormScreen(
          onSave: (Horaire horaire) async {
            try {
              await _horaireService.ajouterHoraire(horaire);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Horaire ajouté avec succès')),
              );
            } catch (e) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Échec de l\'enregistrement')),
              );
            }
          },
        ),
      ),
    );
  }

  void _editHoraire(Horaire horaire) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: HoraireFormScreen(
          horaire: horaire,
          onSave: (Horaire updatedHoraire) async {
            await _horaireService.mettreAJourHoraire(updatedHoraire);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Horaire mis à jour avec succès')),
            );
          },
        ),
      ),
    );
  }

  void _deleteHoraire(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer cet horaire?'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await _horaireService.supprimerHoraire(id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Horaire supprimé avec succès')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Horaires'),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horaires Actifs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gérez tous les horaires de bus disponibles pour vos clients',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Horaire>>(
              stream: _horaireService.getHoraires(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucun horaire disponible'));
                }

                List<Horaire> horaires = snapshot.data!;

                return ListView.builder(
                  itemCount: horaires.length,
                  itemBuilder: (ctx, index) {
                    final horaire = horaires[index];
                    return ListTile(
                      title: Text(horaire.agencyName),
                      subtitle: Text('${horaire.departure} - ${horaire.destination}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editHoraire(horaire),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteHoraire(horaire.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.add),
        onPressed: _addHoraire,
      ),
    );
  }
}

class HoraireFormScreen extends StatefulWidget {
  final Horaire? horaire;
  final Function(Horaire) onSave;

  const HoraireFormScreen({
    Key? key,
    this.horaire,
    required this.onSave,
  }) : super(key: key);

  @override
  _HoraireFormScreenState createState() => _HoraireFormScreenState();
}

class _HoraireFormScreenState extends State<HoraireFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _agencyNameController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();

  File? _image; // Variable pour stocker l'image de l'agence

  DateTime _departureDate = DateTime.now();
  TimeOfDay _departureTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.horaire != null) {
      final h = widget.horaire!;
      _agencyNameController.text = h.agencyName;
      _departureController.text = h.departure;
      _destinationController.text = h.destination;
      _seatsController.text = h.seats; // Changement ici
      _departureDate = DateTime.parse(h.departureDate); // Changement ici
      _departureTime = TimeOfDay.fromDateTime(DateTime.parse(h.time)); // Changement ici
    }
  }

  @override
  void dispose() {
    _agencyNameController.dispose();
    _departureController.dispose();
    _destinationController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _selectDepartureDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _departureDate = pickedDate;
      });
    }
  }

  Future<void> _selectDepartureTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _departureTime,
    );
    if (pickedTime != null) {
      setState(() {
        _departureTime = pickedTime;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _saveHoraire() {
    if (_formKey.currentState!.validate()) {
      final departureDateTime = _combineDateAndTime(_departureDate, _departureTime);

      final horaire = Horaire(
        id: widget.horaire?.id ?? '',
        agencyName: _agencyNameController.text,
        departure: _departureController.text,
        departureDate: departureDateTime.toIso8601String(), // Enregistrement comme String
        destination: _destinationController.text,
        seats: _seatsController.text, // Changement ici
        imageUrl: _image?.path ?? '', // Changement ici
        time: '${_departureTime.hour}:${_departureTime.minute.toString().padLeft(2, '0')}', // Changement ici
      );

      widget.onSave(horaire);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isEditing = widget.horaire != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Center(
              child: Text(
                isEditing ? 'Modifier l\'horaire' : 'Ajouter un nouvel horaire',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _agencyNameController,
              decoration: InputDecoration(
                labelText: 'Nom de l\'agence',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom de l\'agence';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _departureController,
              decoration: InputDecoration(
                labelText: 'Lieu de départ',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le lieu de départ';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: 'Destination',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer la destination';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDepartureDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Date de départ',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: TextEditingController(
                          text: dateFormat.format(_departureDate),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sélectionnez une date';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDepartureTime,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Heure de départ',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: TextEditingController(
                          text: '${_departureTime.hour}:${_departureTime.minute.toString().padLeft(2, '0')}',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sélectionnez une heure';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _seatsController,
              decoration: InputDecoration(
                labelText: 'Nombre de places',
                prefixIcon: Icon(Icons.event_seat),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nombre de places';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Choisir une image de l\'agence'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveHoraire,
              child: Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}