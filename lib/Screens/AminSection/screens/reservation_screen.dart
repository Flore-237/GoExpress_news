import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';

class ReservationsScreen extends StatefulWidget {
  static const routeName = '/reservations';

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ReservationService _reservationService = ReservationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Réservations'),
        backgroundColor: Colors.blue[700],
      ),
      body: StreamBuilder<List<Reservation>>(
        stream: _reservationService.getReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Aucune réservation disponible'),
            );
          }

          List<Reservation> reservations = snapshot.data!;

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (ctx, index) {
              final reservation = reservations[index];
              return ReservationItem(
                reservation: reservation,
                onEdit: () => _editReservation(reservation),
                onDelete: () => _deleteReservation(reservation.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.add),
        onPressed: _addReservation,
      ),
    );
  }

  void _addReservation() {
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
        child: ReservationFormScreen(
          onSave: (Reservation reservation) async {
            await _reservationService.ajouterReservation(reservation);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Réservation ajoutée avec succès')),
            );
          },
        ),
      ),
    );
  }

  void _editReservation(Reservation reservation) {
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
        child: ReservationFormScreen(
          reservation: reservation,
          onSave: (Reservation updatedReservation) async {
            await _reservationService.mettreAJourReservation(updatedReservation);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Réservation mise à jour avec succès')),
            );
          },
        ),
      ),
    );
  }

  void _deleteReservation(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer cette réservation?'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await _reservationService.supprimerReservation(id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Réservation supprimée avec succès')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ReservationItem extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReservationItem({
    Key? key,
    required this.reservation,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.clientName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              reservation.clientEmail,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Horaire ID: ${reservation.horaireId}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Places: ${reservation.nombrePlaces}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${dateFormat.format(reservation.dateReservation)}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Statut: ${reservation.statut}',
              style: TextStyle(
                color: reservation.statut == 'Confirmée' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Modifier'),
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                  ),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  icon: Icon(Icons.delete, size: 16),
                  label: Text('Supprimer'),
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReservationFormScreen extends StatefulWidget {
  final Reservation? reservation;
  final Function(Reservation) onSave;

  const ReservationFormScreen({
    Key? key,
    this.reservation,
    required this.onSave,
  }) : super(key: key);

  @override
  _ReservationFormScreenState createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _horaireIdController = TextEditingController();
  final TextEditingController _nombrePlacesController = TextEditingController();
  DateTime _dateReservation = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.reservation != null) {
      final r = widget.reservation!;
      _clientNameController.text = r.clientName;
      _clientEmailController.text = r.clientEmail;
      _horaireIdController.text = r.horaireId;
      _nombrePlacesController.text = r.nombrePlaces.toString();
      _dateReservation = r.dateReservation;
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _horaireIdController.dispose();
    _nombrePlacesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateReservation,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _dateReservation = pickedDate;
      });
    }
  }

  void _saveReservation() {
    if (_formKey.currentState!.validate()) {
      final reservation = Reservation(
        id: widget.reservation?.id ?? '',
        clientName: _clientNameController.text,
        clientEmail: _clientEmailController.text,
        horaireId: _horaireIdController.text,
        nombrePlaces: _nombrePlacesController.text,
        dateReservation: _dateReservation,
        statut: widget.reservation?.statut ?? 'En attente',
      );

      widget.onSave(reservation);
    }
  }
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isEditing = widget.reservation != null;

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
                isEditing ? 'Modifier la réservation' : 'Ajouter une nouvelle réservation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _clientNameController,
              decoration: InputDecoration(
                labelText: 'Nom du client',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du client';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _clientEmailController,
              decoration: InputDecoration(
                labelText: 'Email du client',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'email du client';
                }
                if (!value.contains('@')) {
                  return 'Veuillez entrer un email valide';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _horaireIdController,
              decoration: InputDecoration(
                labelText: 'ID de l\'horaire',
                prefixIcon: Icon(Icons.schedule),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'ID de l\'horaire';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nombrePlacesController,
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
                if (int.tryParse(value) == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Date de réservation',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller: TextEditingController(
                    text: dateFormat.format(_dateReservation),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReservation,
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