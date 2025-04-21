import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class ReservationSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Génère un numéro de réservation
  String generateReservationNumber() {
    final now = DateTime.now();
    final year = now.year;
    final random = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return 'RES-$year-$random';
  }

  // Génère des données QR Code
  String generateQRCodeData(String reservationId, String passengerName) {
    return 'RES:$reservationId|PASS:$passengerName|DATE:${DateTime.now().toIso8601String()}';
  }

  // Génère des données code barres
  String generateBarcodeData(String reservationId) {
    return reservationId.replaceAll('-', '').substring(0, 12).padRight(12, '0');
  }

  // Génère un numéro de transaction
  String generateTransactionNumber() {
    final now = DateTime.now();
    final random = (now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0');
    return 'TXN-${now.year}${now.month}${now.day}-$random';
  }

  // Génère une référence de paiement
  String generatePaymentReference() {
    final now = DateTime.now();
    final random = (now.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
    return 'PAY-${now.hour}${now.minute}-$random';
  }

  Future<DocumentSnapshot> getAgenceInfo(String agenceId) async {
    return await _firestore.collection('agences').doc(agenceId).get();
  }

  Future<DocumentSnapshot> getVoyageInfo(String voyageId) async {
    return await _firestore.collection('voyages').doc(voyageId).get();
  }

  Future<String> createReservation({
    required String voyageId,
    required String itineraireId,
    required String agenceId,
    required String userId,
    required String typePlace,
    required int nombrePlaces,
    required double montantTotal,
    required List<Map<String, dynamic>> passagers,
    required List<String> numerosPlaces,
    required String email,
    required String telephone,
    required String adresse,
  }) async {
    final batch = _firestore.batch();

    // 1. Créer la réservation
    final reservationRef = _firestore.collection('reservations').doc();
    final numeroReservation = generateReservationNumber();

    batch.set(reservationRef, {
      'id': reservationRef.id,
      'voyageId': voyageId,
      'itineraireId': itineraireId,
      'agenceId': agenceId,
      'userId': userId,
      'dateReservation': FieldValue.serverTimestamp(),
      'typePlace': typePlace,
      'nombrePlaces': nombrePlaces,
      'montantTotal': montantTotal,
      'statut': 'en attente',
      'numeroReservation': numeroReservation,
      'passagers': passagers,
      'numerosPlaces': numerosPlaces,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'dateExpiration': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24))
      ),
    });

    // 2. Mettre à jour les places disponibles
    final voyageRef = _firestore.collection('voyages').doc(voyageId);
    final fieldToUpdate = typePlace == 'VIP'
        ? 'placesVIPDisponibles'
        : 'placesStandardDisponibles';

    batch.update(voyageRef, {
      fieldToUpdate: FieldValue.increment(-nombrePlaces),
    });

    // 3. Créer un ticket pour chaque passager
    for (int i = 0; i < passagers.length; i++) {
      final ticketRef = _firestore.collection('tickets').doc();
      batch.set(ticketRef, {
        'id': ticketRef.id,
        'reservationId': reservationRef.id,
        'userId': userId,
        'agenceId': agenceId,
        'voyageId': voyageId,
        'codeQR': generateQRCodeData(reservationRef.id, passagers[i]['nom']),
        'codeBarres': generateBarcodeData(reservationRef.id),
        'dateGeneration': FieldValue.serverTimestamp(),
        'statut': 'valide',
        'infoPassager': passagers[i],
        'classe': typePlace,
        'numeroPlace': numerosPlaces[i],
      });
    }

    // 4. Créer une notification
    final notificationRef = _firestore.collection('notifications').doc();
    batch.set(notificationRef, {
      'id': notificationRef.id,
      'userId': userId,
      'titre': 'Confirmation de réservation',
      'message': 'Votre réservation $numeroReservation a été enregistrée. Veuillez la payer dans les 24h.',
      'dateEnvoi': FieldValue.serverTimestamp(),
      'type': 'reservation',
      'lu': false,
      'lienAction': '/reservations/${reservationRef.id}',
    });

    await batch.commit();
    return reservationRef.id;
  }

  Future<void> processPayment({
    required String reservationId,
    required String userId,
    required double montant,
    required String methodePaiement,
    String? transactionId,
  }) async {
    final paymentRef = _firestore.collection('paiements').doc();
    final reservationRef = _firestore.collection('reservations').doc(reservationId);

    await _firestore.runTransaction((transaction) async {
      final reservationDoc = await transaction.get(reservationRef);
      if (!reservationDoc.exists) {
        throw Exception('Reservation non trouvée');
      }
      if (reservationDoc.data()?['statut'] == 'payé') {
        throw Exception('Reservation déjà payée');
      }

      transaction.set(paymentRef, {
        'id': paymentRef.id,
        'reservationId': reservationId,
        'userId': userId,
        'montant': montant,
        'methodePaiement': methodePaiement,
        'numeroTransaction': transactionId ?? generateTransactionNumber(),
        'datePaiement': FieldValue.serverTimestamp(),
        'statutPaiement': 'complet',
        'reference': generatePaymentReference(),
      });

      transaction.update(reservationRef, {
        'statut': 'payé',
        'datePaiement': FieldValue.serverTimestamp(),
      });

      final notificationRef = _firestore.collection('notifications').doc();
      transaction.set(notificationRef, {
        'id': notificationRef.id,
        'userId': userId,
        'titre': 'Paiement confirmé',
        'message': 'Votre paiement pour la réservation ${reservationDoc.data()?['numeroReservation']} a été accepté',
        'dateEnvoi': FieldValue.serverTimestamp(),
        'type': 'paiement',
        'lu': false,
        'lienAction': '/reservations/$reservationId',
      });
    });
  }
}

// Thème et constantes
class AppTheme {
  static const Color primaryColor = Color(0xFF1A5276);
  static const Color accentColor = Color(0xFFF39C12);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);

  static ThemeData theme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: primaryColor,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardTheme(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: const TextStyle(color: textSecondary),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary
      ),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondary,
      ),
    ),
  );
}

class ReservationScreen extends StatefulWidget {
  final String voyageId;
  final String agenceId;
  final String userId;
  final String typePlace;
  final double prix;
  final String departure;
  final String destination;
  final String dateDepart;
  final String heureDepart;

  const ReservationScreen({
    Key? key,
    required this.voyageId,
    required this.agenceId,
    required this.userId,
    required this.typePlace,
    required this.prix,
    required this.departure,
    required this.destination,
    required this.dateDepart,
    required this.heureDepart,
  }) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reservationSystem = ReservationSystem();
  final List<PassengerForm> _passengerForms = [];
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  int _currentStep = 0;
  bool _isProcessing = false;
  bool _acceptTerms = false;
  Map<String, dynamic>? _agenceDetails;
  Map<String, dynamic>? _voyageDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _addPassengerField();
    _loadAgenceAndVoyageInfo();
  }

  Future<void> _loadAgenceAndVoyageInfo() async {
    setState(() => _isLoading = true);
    try {
      final agenceDoc = await _reservationSystem.getAgenceInfo(widget.agenceId);
      final voyageDoc = await _reservationSystem.getVoyageInfo(widget.voyageId);

      setState(() {
        _agenceDetails = agenceDoc.data() as Map<String, dynamic>?;
        _voyageDetails = voyageDoc.data() as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Erreur de chargement des informations');
    }
  }

  @override
  void dispose() {
    for (var form in _passengerForms) {
      form.dispose();
    }
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _addPassengerField() {
    _passengerForms.add(PassengerForm(
      nameController: TextEditingController(),
      idController: TextEditingController(),
      ageController: TextEditingController(),
    ));
    setState(() {});
  }

  void _removePassengerField(int index) {
    if (_passengerForms.length > 1) {
      _passengerForms[index].dispose();
      _passengerForms.removeAt(index);
      setState(() {});
    }
  }

  String generateSeatNumber(String typePlace, int index) {
    final prefix = typePlace == 'VIP' ? 'V' : 'S';
    return '$prefix-${(index + 1).toString().padLeft(2, '0')}';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez accepter les conditions générales     ')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final passagers = _passengerForms.map((form) => {
        'nom': form.nameController.text.trim(),
        'identifiant': form.idController.text.trim(),
        'age': int.tryParse(form.ageController.text.trim()) ?? 0,
      }).toList();

      final numerosPlaces = List.generate(
        _passengerForms.length,
            (index) => generateSeatNumber(widget.typePlace, index),
      );

      final reservationId = await _reservationSystem.createReservation(
        voyageId: widget.voyageId,
        itineraireId: _voyageDetails?['itineraireId'] ?? '',
        agenceId: widget.agenceId,
        userId: widget.userId,
        typePlace: widget.typePlace,
        nombrePlaces: _passengerForms.length,
        montantTotal: widget.prix * _passengerForms.length,
        passagers: passagers,
        numerosPlaces: numerosPlaces,
        email: _emailController.text.trim(),
        telephone: _phoneController.text.trim(),
        adresse: _addressController.text.trim(),
      );

      // Naviguez vers l'écran de paiement avec l'ID de réservation réel
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              reservationId: reservationId,
              userId: widget.userId,
              montant: widget.prix * _passengerForms.length,
              agenceName: _agenceDetails?['nom'] ?? 'Agence',
              voyage: VoyageDetails(
                departure: widget.departure,
                destination: widget.destination,
                dateDepart: widget.dateDepart,
                heureDepart: widget.heureDepart,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Échec de la réservation: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Réservation de billets'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep == 0 && _formKey.currentState!.validate()) {
                    setState(() => _currentStep += 1);
                  } else if (_currentStep == 1) {
                    _submitReservation();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  }
                },
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        if (_currentStep != 0)
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: details.onStepCancel,
                              child: const Text('Retour'),
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : details.onStepContinue,
                            child: _isProcessing
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(_currentStep == 1 ? 'Confirmer la réservation' : 'Continuer'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    isActive: _currentStep >= 0,
                    title: const Text('Informations'),
                    content: _buildInformationStep(),
                  ),
                  Step(
                    isActive: _currentStep >= 1,
                    title: const Text('Récapitulatif'),
                    content: _buildSummaryStep(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.departure} → ${widget.destination}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    widget.dateDepart,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    widget.heureDepart,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.airline_seat_recline_normal, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    widget.typePlace,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_agenceDetails != null)
            Text(
              'Agence: ${_agenceDetails!['nom']}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInformationStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations de contact',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Champ requis';
                      if (!value.contains('@')) return 'Email invalide';
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone),
                      hintText: '+225 XX XX XX XX',
                    ),
                    validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Informations passagers',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: _addPassengerField,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._buildPassengerFormCards(),
        ],
      ),
    );
  }

  List<Widget> _buildPassengerFormCards() {
    return List.generate(_passengerForms.length, (index) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Passager ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_passengerForms.length > 1)
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.error),
                      onPressed: () => _removePassengerField(index),
                      tooltip: 'Supprimer ce passager',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 24,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passengerForms[index].nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passengerForms[index].idController,
                decoration: const InputDecoration(
                  labelText: 'N° Pièce d\'identité',
                  prefixIcon: Icon(Icons.badge),
                  hintText: 'CNI, Passeport, etc.',
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passengerForms[index].ageController,
                decoration: const InputDecoration(
                  labelText: 'Âge',
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Champ requis';
                  if (int.tryParse(value) == null) return 'Âge invalide';
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryStep() {
    final totalAmount = widget.prix * _passengerForms.length;
    final formattedTotal = NumberFormat.currency(
      symbol: 'FCFA ',
      decimalDigits: 0,
    ).format(totalAmount);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    Card(
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Détails du voyage',
    style: Theme.of(context).textTheme.titleMedium,
    ),
    const Divider(),
    _buildDetailRow(
    'Trajet',
    '${widget.departure} → ${widget.destination}',
    Icons.route,
    ),
    _buildDetailRow(
    'Date',
    widget.dateDepart,
    Icons.calendar_today,
    ),
    _buildDetailRow(
    'Heure de départ',
    widget.heureDepart,
    Icons.access_time,
    ),
    _buildDetailRow(
    'Classe',
    widget.typePlace,
    Icons.airline_seat_recline_normal,
    ),
    if (_agenceDetails != null) ...[
    _buildDetailRow(
    'Agence',
    _agenceDetails!['nom'],
    Icons.business,
    ),
    ],
    if (_voyageDetails != null && _voyageDetails!.containsKey('chauffeur')) ...[
    _buildDetailRow(
    'Chauffeur',
    _voyageDetails!['chauffeur'],
    Icons.person,
    ),
    ],
    if (_voyageDetails != null && _voyageDetails!.containsKey('vehicule')) ...[
    _buildDetailRow(
    'Véhicule',
    _voyageDetails!['vehicule'],
    Icons.directions_bus,
    ),
    ],
    ],
    ),
    ),
    ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails des passagers',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  ..._passengerForms.asMap().entries.map((entry) {
                    final index = entry.key;
                    final form = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                      'Passager ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildPassengerDetailRow('Nom', form.nameController.text),
                      _buildPassengerDetailRow('Pièce d\'identité', form.idController.text),
                      _buildPassengerDetailRow('Âge', '${form.ageController.text} ans'),
                      _buildPassengerDetailRow(
                        'Siège',
                        generateSeatNumber(widget.typePlace, index),
                      )
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Récapitulatif du paiement',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  _buildPaymentDetailRow('Prix unitaire', widget.prix),
                  _buildPaymentDetailRow('Nombre de places', _passengerForms.length),
                  const Divider(),
                  _buildPaymentDetailRow(
                    'Total à payer',
                    totalAmount,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'J\'accepte les '),
                      TextSpan(
                        text: 'conditions générales',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Afficher les conditions générales
                          },
                      ),
                      const TextSpan(text: ' de vente et d\'utilisation'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, dynamic value, {bool isTotal = false}) {
    final formattedValue = value is num
        ? NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0).format(value)
        : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isTotal ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            formattedValue,
            style: TextStyle(
              color: isTotal ? AppTheme.primaryColor : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class PassengerForm {
  final TextEditingController nameController;
  final TextEditingController idController;
  final TextEditingController ageController;

  PassengerForm({
    required this.nameController,
    required this.idController,
    required this.ageController,
  });

  void dispose() {
    nameController.dispose();
    idController.dispose();
    ageController.dispose();
  }
}

class PaymentScreen extends StatelessWidget {
  final String reservationId;
  final String userId;
  final double montant;
  final String agenceName;
  final VoyageDetails voyage;

  const PaymentScreen({
    Key? key,
    required this.reservationId,
    required this.userId,
    required this.montant,
    required this.agenceName,
    required this.voyage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: 'FCFA ',
      decimalDigits: 0,
    ).format(montant);

    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paiement'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Résumé de la réservation',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Divider(),
                      _buildDetailRow('Agence', agenceName, Icons.business),
                      _buildDetailRow(
                        'Trajet',
                        '${voyage.departure} → ${voyage.destination}',
                        Icons.route,
                      ),
                      _buildDetailRow(
                        'Date',
                        voyage.dateDepart,
                        Icons.calendar_today,
                      ),
                      _buildDetailRow(
                        'Heure',
                        voyage.heureDepart,
                        Icons.access_time,
                      ),
                      _buildDetailRow(
                        'Montant total',
                        formattedAmount,
                        Icons.payment,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Méthodes de paiement',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildPaymentMethod(
                context,
                icon: Icons.mobile_friendly,
                title: 'Mobile Money',
                description: 'Paiement via Orange Money, MTN Mobile Money, etc.',
                onTap: () => _processPayment(context, 'mobile_money'),
              ),
              const SizedBox(height: 16),
              _buildPaymentMethod(
                context,
                icon: Icons.credit_card,
                title: 'Carte bancaire',
                description: 'Paiement sécurisé par carte Visa/Mastercard',
                onTap: () => _processPayment(context, 'carte_bancaire'),
              ),
              const SizedBox(height: 16),
              _buildPaymentMethod(
                context,
                icon: Icons.account_balance,
                title: 'Virement bancaire',
                description: 'Transfert direct depuis votre compte bancaire',
                onTap: () => _processPayment(context, 'virement_bancaire'),
              ),
              const SizedBox(height: 16),
              _buildPaymentMethod(
                context,
                icon: Icons.money,
                title: 'Espèces',
                description: 'Paiement en agence ou chez un partenaire agréé',
                onTap: () => _processPayment(context, 'especes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, String method) async {
    final reservationSystem = ReservationSystem();
    final navigator = Navigator.of(context);

    try {
      await reservationSystem.processPayment(
        reservationId: reservationId,
        userId: userId,
        montant: montant,
        methodePaiement: method,
      );

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paiement effectué avec succès!'),
          backgroundColor: AppTheme.success,
        ),
      );

      // Naviguer vers l'écran de confirmation
      await navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            reservationId: reservationId,
            montant: montant,
            agenceName: agenceName,
            voyage: voyage,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de paiement: ${e.toString()}'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}

class ConfirmationScreen extends StatelessWidget {
  final String reservationId;
  final double montant;
  final String agenceName;
  final VoyageDetails voyage;

  const ConfirmationScreen({
    Key? key,
    required this.reservationId,
    required this.montant,
    required this.agenceName,
    required this.voyage,
  }) : super(key: key);

  get SvgPicture => null;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: 'FCFA ',
      decimalDigits: 0,
    ).format(montant);

    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Confirmation'),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/success.svg',
                        height: 100,
                        color: AppTheme.success,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Paiement confirmé!',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Votre réservation a été confirmée et payée avec succès.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          reservationId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails du voyage',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Divider(),
                      _buildDetailRow('Agence', agenceName),
                      _buildDetailRow('Trajet', '${voyage.departure} → ${voyage.destination}'),
                      _buildDetailRow('Date', voyage.dateDepart),
                      _buildDetailRow('Heure de départ', voyage.heureDepart),
                      const Divider(),
                      _buildDetailRow('Montant total', formattedAmount),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Vos billets ont été envoyés par email. Vous pouvez aussi les télécharger ci-dessous.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Télécharger les billets
                },
                icon: const Icon(Icons.download),
                label: const Text('Télécharger les billets'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                  );
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class VoyageDetails {
  final String departure;
  final String destination;
  final String dateDepart;
  final String heureDepart;

  const VoyageDetails({
    required this.departure,
    required this.destination,
    required this.dateDepart,
    required this.heureDepart,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: const Center(child: Text('Page d\'accueil')),
    );
  }
}
