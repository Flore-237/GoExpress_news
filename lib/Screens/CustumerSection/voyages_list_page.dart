import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'travel_details_screen.dart';

class VoyagesListPage extends StatefulWidget {
  final String? depart;
  final String? destination;
  final String? dateAller;
  final String? heureAller;
  final String? agency;
  final String? itineraireId;
  final Map<String, dynamic>? itineraireData;
  final Map<String, dynamic>? agenceData;
  final String? agenceId;

  const VoyagesListPage({
    Key? key,
    this.depart,
    this.destination,
    this.dateAller,
    this.heureAller,
    this.agency,
    this.itineraireId,
    this.itineraireData,
    this.agenceData,
    this.agenceId,
  }) : super(key: key);

  @override
  _VoyagesListPageState createState() => _VoyagesListPageState();
}

class _VoyagesListPageState extends State<VoyagesListPage> {
  List<Map<String, dynamic>> _voyages = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  Future<void> _fetchVoyages() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _hasError = false;
        _voyages = [];
      });


      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('voyages')
          .where('statut', isEqualTo: 'programmé');

      if (widget.depart != null) {
        query = query.where('depart', isEqualTo: widget.depart);
      }

      if (widget.destination != null) {
        query = query.where('destination', isEqualTo: widget.destination);
      }

      if (widget.agency != null) {
        query = query.where('agenceId', isEqualTo: widget.agency);
      }

      if (widget.dateAller != null) {
        query = query.where('dateDepart', isEqualTo: widget.dateAller);
      }

      // Exécution de la requête
      final voyagesSnapshot = await query.get();

      final List<Map<String, dynamic>> voyagesList = [];

      for (final voyageDoc in voyagesSnapshot.docs) {
        final voyageData = voyageDoc.data();


        if (widget.heureAller != null) {
          final heureVoyage = voyageData['heureDepart']?.toString() ?? '';
          if (!_matchTimeFilter(heureVoyage, widget.heureAller!)) {
            continue;
          }
        }

        final agenceDoc = await FirebaseFirestore.instance
            .collection('agences')
            .doc(voyageData['agenceId'])
            .get();

        // Récupérer les données de l'itinéraire si nécessaire
        final itineraireDoc = await FirebaseFirestore.instance
            .collection('itineraires')
            .doc(voyageData['itineraireId'])
            .get();

        voyagesList.add({
          'id': voyageDoc.id,
          ...voyageData,
          'agenceData': agenceDoc.data(),
          'itineraireData': itineraireDoc.data(),
        });
      }

      // Tri des résultats par date et heure
      voyagesList.sort((a, b) {
        // D'abord par date de départ
        int dateCompare = a['dateDepart'].compareTo(b['dateDepart']);
        if (dateCompare != 0) return dateCompare;

        // Ensuite par heure de départ
        return a['heureDepart'].compareTo(b['heureDepart']);
      });

      if (!mounted) return;
      setState(() {
        _voyages = voyagesList;
        _isLoading = false;
        _isRefreshing = false;
      });
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.code} - ${e.message}');

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _isRefreshing = false;
        _errorMessage = 'Erreur lors du chargement des données';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('Erreur récupération voyages: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _isRefreshing = false;
        _errorMessage = 'Erreur inattendue';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  bool _matchTimeFilter(String voyageHeure, String filterHeure) {
    try {
      final format = DateFormat('HH:mm');
      final voyageTime = format.parse(voyageHeure.trim());
      final filterTime = format.parse(filterHeure.trim());

      final lowerBound = filterTime.subtract(const Duration(hours: 1));
      final upperBound = filterTime.add(const Duration(hours: 1));

      return voyageTime.isAfter(lowerBound) && voyageTime.isBefore(upperBound);
    } catch (e) {
      debugPrint('Erreur de comparaison des heures: $e');
      return false;
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _fetchVoyages();
  }

  @override
  void initState() {
    super.initState();
    _fetchVoyages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voyages disponibles',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3D56F0),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : _hasError
                  ? _buildErrorWidget()
                  : _voyages.isEmpty
                  ? _buildEmptyState()
                  : _buildVoyagesList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.depart != null || widget.destination != null)
            Text(
              '${widget.depart ?? ''} → ${widget.destination ?? ''}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (widget.dateAller != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  _formatDate(widget.dateAller!),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
          if (widget.heureAller != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Autour de ${widget.heureAller}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
          if (widget.agency != null) ...[
            const SizedBox(height: 8),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('agences')
                  .doc(widget.agency)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final agenceData = snapshot.data!.data() as Map<String, dynamic>;
                  return Row(
                    children: [
                      const Icon(Icons.business, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        agenceData['nom'] ?? 'Agence inconnue',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final displayFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
      final date = dateFormat.parse(dateStr);
      return displayFormat.format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Recherche des voyages...',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Erreur lors de la recherche',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Veuillez vérifier votre connexion internet',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_schedule.png', width: 120, height: 120),
          const SizedBox(height: 16),
          const Text('Aucun voyage trouvé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              widget.dateAller != null
                  ? 'Aucun voyage correspondant à vos critères. Essayez avec des paramètres différents.'
                  : 'Aucun voyage disponible pour cette recherche.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoyagesList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _voyages.length,
      itemBuilder: (context, index) {
        final voyage = _voyages[index];
        return _buildVoyageCard(voyage);
      },
    );
  }

  Widget _buildVoyageCard(Map<String, dynamic> voyage) {
    final heureDepart = voyage['heureDepart']?.toString() ?? '--:--';
    final heureArrivee = voyage['heureArriveeEstimee']?.toString() ?? '--:--';
    final dateDepart = voyage['dateDepart']?.toString() ?? '';
    final agenceData = voyage['agenceData'] as Map<String, dynamic>? ?? {};
    final itineraireData = voyage['itineraireData'] as Map<String, dynamic>? ?? {};

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // En-tête avec l'agence
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
                  child: agenceData['logo'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      agenceData['logo'].toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.business, size: 20),
                    ),
                  )
                      : const Icon(Icons.business, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agenceData['nom']?.toString() ?? 'Agence inconnue',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            (agenceData['note'] as num?)?.toStringAsFixed(1) ?? 'N/A',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date du voyage
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  _formatDate(dateDepart),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Détails du voyage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text('DÉPART',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(heureDepart,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(voyage['depart']?.toString() ?? '',
                        style:
                        TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                Column(
                  children: [
                    Text('${((itineraireData['duree'] as num? ?? 0) / 60).toStringAsFixed(1)} h',
                        style: TextStyle(color: Colors.grey[600])),
                    const Icon(Icons.directions_bus, color: Colors.blue),
                  ],
                ),
                Column(
                  children: [
                    const Text('ARRIVÉE',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(heureArrivee,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(voyage['destination']?.toString() ?? '',
                        style:
                        TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Prix et disponibilité
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceInfo(
                    'Classique',
                    voyage['prixClassique']?.toString() ?? '0',
                    voyage['placesClassiqueDisponibles']?.toString() ?? '0',
                  ),
                  _buildPriceInfo(
                    'VIP',
                    voyage['prixVIP']?.toString() ?? '0',
                    voyage['placesVIPDisponibles']?.toString() ?? '0',
                    isVIP: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bouton de réservation
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D56F0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Correction ici pour s'assurer que les valeurs ne sont pas nulles
                  final String voyageId = voyage['id'] ?? '';
                  final String agenceId = voyage['agenceId'] ?? '';
                  final String itineraireId = voyage['itineraireId'] ?? '';
                  final String depart = voyage['depart'] ?? '';
                  final String destination = voyage['destination'] ?? '';
                  final String dateDepart = voyage['dateDepart'] ?? '';
                  final String heureDepart = voyage['heureDepart'] ?? '';

                  // Navigation directe vers l'écran de réservation au lieu de VoyageDetailsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationScreen(
                        voyageId: voyageId,
                        agenceId: agenceId,
                        userId: 'user123', // Remplacer par l'ID de l'utilisateur actuel
                        typePlace: 'Classique', // Type par défaut, à changer selon le besoin
                        prix: double.tryParse(voyage['prixClassique']?.toString() ?? '0') ?? 0,
                        departure: depart,
                        destination: destination,
                        dateDepart: dateDepart,
                        heureDepart: heureDepart,
                      ),
                    ),
                  );
                },
                child: const Text('Réserver ce voyage',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, String price, String available,
      {bool isVIP = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text('$price FCFA',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isVIP ? const Color(0xFF3D56F0) : Colors.black)),
        const SizedBox(height: 4),
        Text('$available places',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

// Importation de l'écran de réservation directement ici
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
  final List<TextEditingController> _passengerControllers = [];
  final TextEditingController _seatsController = TextEditingController(text: '1');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  int _currentStep = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _addPassengerField();
  }

  @override
  void dispose() {
    for (var controller in _passengerControllers) {
      controller.dispose();
    }
    _seatsController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _addPassengerField() {
    _passengerControllers.add(TextEditingController());
    setState(() {});
  }

  void _removePassengerField(int index) {
    if (_passengerControllers.length > 1) {
      _passengerControllers[index].dispose();
      _passengerControllers.removeAt(index);
      setState(() {});
    }
  }

  String generateSeatNumber(String typePlace) {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    return '${typePlace.substring(0, 1)}-${random.toString().padLeft(2, '0')}';
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final passagers = _passengerControllers
          .map((controller) => {'nom': controller.text.trim()})
          .toList();

      final numerosPlaces = List.generate(
        _passengerControllers.length,
            (index) => generateSeatNumber(widget.typePlace),
      );

      // Générer un ID unique pour la réservation
      final String reservationId = 'RES-${DateTime.now().millisecondsSinceEpoch}';

      await _reservationSystem.createReservation(
        voyageId: widget.voyageId,
        itineraireId: 'default-itineraire', // Remplacer par l'ID réel
        agenceId: widget.agenceId,
        userId: widget.userId,
        typePlace: widget.typePlace,
        nombrePlaces: _passengerControllers.length,
        montantTotal: widget.prix * _passengerControllers.length,
        passagers: passagers,
        numerosPlaces: numerosPlaces,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            reservationId: reservationId,
            userId: widget.userId,
            montant: widget.prix * _passengerControllers.length,
          ),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: Text('Échec de la réservation: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stepper(
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
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Retour'),
                  ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : Text(_currentStep == 1 ? 'Confirmer' : 'Continuer'),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Informations personnelles'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) => value!.isEmpty ? 'Requis' : null,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) => value!.isEmpty ? 'Requis' : null,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  ..._buildPassengerFields(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addPassengerField,
                    tooltip: 'Ajouter un passager',
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Récapitulatif'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReservationDetail(
                  'Trajet',
                  '${widget.departure} → ${widget.destination}',
                ),
                _buildReservationDetail(
                  'Date et heure',
                  '${widget.dateDepart} à ${widget.heureDepart}',
                ),
                _buildReservationDetail(
                  'Classe',
                  widget.typePlace,
                ),
                _buildReservationDetail(
                  'Nombre de passagers',
                  _passengerControllers.length.toString(),
                ),
                _buildReservationDetail(
                  'Prix total',
                  '${widget.prix * _passengerControllers.length} FCFA',
                  isPrice: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Passagers:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._passengerControllers.map((controller) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(controller.text),
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPassengerFields() {
    return List.generate(_passengerControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _passengerControllers[index],
                decoration: InputDecoration(
                  labelText: 'Passager ${index + 1}',
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
            ),
            if (_passengerControllers.length > 1)
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _removePassengerField(index),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildReservationDetail(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: isPrice
                ? const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green)
                : null,
          ),
        ],
      ),
    );
  }
}

class ReservationSystem {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateReservationNumber() {
    final now = DateTime.now();
    final random = now.millisecondsSinceEpoch % 10000;
    return 'RES-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${random.toString().padLeft(4, '0')}';
  }

  Future<void> createReservation({
    required String voyageId,
    required String itineraireId,
    required String agenceId,
    required String userId,
    required String typePlace,
    required int nombrePlaces,
    required double montantTotal,
    required List<Map<String, dynamic>> passagers,
    required List<String> numerosPlaces,
  }) async {
    final reservationId = _firestore.collection('reservations').doc().id;
    final reservationNumber = generateReservationNumber();
    final now = DateTime.now();

    // Créer la réservation
    await _firestore.collection('reservations').doc(reservationId).set({
      'id': reservationId,
      'numeroReservation': reservationNumber,
      'voyageId': voyageId,
      'itineraireId': itineraireId,
      'agenceId': agenceId,
      'userId': userId,
      'typePlace': typePlace,
      'nombrePlaces': nombrePlaces,
      'montantTotal': montantTotal,
      'statut': 'en attente',
      'dateCreation': now,
      'dateModification': now,
      'passagers': passagers,
      'numerosPlaces': numerosPlaces,
    });

    // Mettre à jour les places disponibles dans le voyage
    final voyageRef = _firestore.collection('voyages').doc(voyageId);
    final fieldToUpdate = typePlace == 'VIP'
        ? 'placesVIPDisponibles'
        : 'placesClassiqueDisponibles';

    await voyageRef.update({
      fieldToUpdate: FieldValue.increment(-nombrePlaces),
    });
  }
}

class PaymentScreen extends StatelessWidget {
  final String reservationId;
  final String userId;
  final double montant;

  const PaymentScreen({
    Key? key,
    required this.reservationId,
    required this.userId,
    required this.montant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé de votre réservation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPaymentDetail('Numéro de réservation', reservationId),
            _buildPaymentDetail('Montant total', '$montant FCFA'),
            const SizedBox(height: 32),
            const Text(
              'Méthodes de paiement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethod(
              icon: Icons.credit_card,
              title: 'Carte bancaire',
              onTap: () => _processPayment(context, 'carte'),
            ),
            _buildPaymentMethod(
              icon: Icons.mobile_friendly,
              title: 'Mobile Money',
              onTap: () => _processPayment(context, 'mobile_money'),
            ),
            _buildPaymentMethod(
              icon: Icons.money,
              title: 'Espèces (à l\'agence)',
              onTap: () => _processPayment(context, 'especes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF3D56F0)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _processPayment(BuildContext context, String method) async {
    try {
      // Simuler un traitement de paiement
      await Future.delayed(const Duration(seconds: 2));

      // Mettre à jour le statut de la réservation
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .update({
        'statut': 'confirmée',
        'methodePaiement': method,
        'dateModification': DateTime.now(),
      });

      // Naviguer vers l'écran de confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            reservationId: reservationId,
            montant: montant,
            paymentMethod: method,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de paiement: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ConfirmationScreen extends StatelessWidget {
  final String reservationId;
  final double montant;
  final String paymentMethod;

  const ConfirmationScreen({
    Key? key,
    required this.reservationId,
    required this.montant,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Paiement réussi!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Numéro de réservation: $reservationId',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Montant: $montant FCFA',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Méthode: ${_formatPaymentMethod(paymentMethod)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'carte':
        return 'Carte bancaire';
      case 'mobile_money':
        return 'Mobile Money';
      case 'especes':
        return 'Espèces';
      default:
        return method;
    }
  }
}