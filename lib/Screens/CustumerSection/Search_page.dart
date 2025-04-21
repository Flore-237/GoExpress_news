import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'voyages_list_page.dart';

class SearchPage extends StatefulWidget {
  final String departure;
  final String destination;
  final String? dateAller;
  final String? heureAller;
  final String? agency;

  const SearchPage({
    Key? key,
    required this.departure,
    required this.destination,
    this.dateAller,
    this.heureAller,
    this.agency,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _itinerairesWithAgency = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isRefreshing = false;
  String _errorMessage = '';

  // Nouveaux états pour les listes de départs et destinations
  List<String> _departuresList = [];
  List<String> _destinationsList = [];
  bool _loadingDepartures = false;
  bool _loadingDestinations = false;

  @override
  void initState() {
    super.initState();
    _fetchItinerairesWithAgencies();
    // Initialiser les listes vides au démarrage
    _departuresList = [];
    _destinationsList = [];
  }

  // Méthode pour récupérer les départs uniques depuis Firestore
  Future<void> _fetchDepartures() async {
    if (_loadingDepartures) return;

    setState(() {
      _loadingDepartures = true;
    });

    try {
      // Récupération des données depuis la collection 'agences'
      final querySnapshot = await FirebaseFirestore.instance
          .collection('agences')
          .get();

      // Extraction des départs sans doublons
      final departures = <String>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['departure'] != null) {
          departures.add(data['departure'].toString());
        }
      }

      setState(() {
        _departuresList = departures.toList()..sort();
        _loadingDepartures = false;
      });
    } catch (e) {
      setState(() {
        _loadingDepartures = false;
      });
      // On ne montre pas d'erreur à l'utilisateur pour ne pas perturber l'expérience
      debugPrint('Erreur lors de la récupération des départs: $e');
    }
  }

  // Méthode pour récupérer les destinations uniques depuis Firestore
  Future<void> _fetchDestinations() async {
    if (_loadingDestinations) return;

    setState(() {
      _loadingDestinations = true;
    });

    try {
      // Récupération des données depuis la collection 'agences'
      final querySnapshot = await FirebaseFirestore.instance
          .collection('agences')
          .get();

      // Extraction des destinations sans doublons
      final destinations = <String>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['destination'] != null) {
          destinations.add(data['destination'].toString());
        }
      }

      setState(() {
        _destinationsList = destinations.toList()..sort();
        _loadingDestinations = false;
      });
    } catch (e) {
      setState(() {
        _loadingDestinations = false;
      });
      // On ne montre pas d'erreur à l'utilisateur pour ne pas perturber l'expérience
      debugPrint('Erreur lors de la récupération des destinations: $e');
    }
  }

  Future<void> _fetchItinerairesWithAgencies() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _itinerairesWithAgency = [];
    });

    try {
      // 1. Vérification de la connexion à Firestore
      try {
        await FirebaseFirestore.instance.collection('itineraires').limit(1).get();
      } catch (e) {
        throw Exception('Connexion à Firestore échouée. Vérifiez votre connexion internet.');
      }

      debugPrint('Recherche d\'itinéraires: ${widget.departure} → ${widget.destination}');

      // 2. Construction de la requête avec normalisation des données
      var query = FirebaseFirestore.instance
          .collection('itineraires')
          .where('departure', isEqualTo: widget.departure.trim().toLowerCase())
          .where('destination', isEqualTo: widget.destination.trim().toLowerCase())
          .where('active', isEqualTo: true);

      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      debugPrint('${snapshot.docs.length} itinéraires trouvés dans la requête initiale');

      final List<Map<String, dynamic>> results = [];

      // 3. Parcours des résultats et jointure avec les agences
      for (final doc in snapshot.docs) {
        try {
          final itineraire = doc.data() ?? {};
          final String agenceId = itineraire['agenceId']?.toString() ?? '';

          if (agenceId.isEmpty) {
            debugPrint('Itinéraire ${doc.id} ignoré: pas d\'agenceId');
            continue;
          }

          // 4. Récupération des données de l'agence
          final agenceDoc = await FirebaseFirestore.instance
              .collection('agences')
              .doc(agenceId)
              .get();

          if (!agenceDoc.exists) {
            debugPrint('Agence $agenceId non trouvée pour itinéraire ${doc.id}');
            continue;
          }

          final agenceData = agenceDoc.data();
          if (agenceData == null) {
            debugPrint('Données agence $agenceId vides');
            continue;
          }

          // 5. Filtrage par agence si spécifié
          if (widget.agency != null && agenceDoc.id != widget.agency) {
            continue;
          }

          results.add({
            'itineraireId': doc.id,
            'itineraireData': itineraire,
            'agence': agenceData,
            'agenceId': agenceDoc.id,
          });
        } catch (e) {
          debugPrint('Erreur traitement itinéraire ${doc.id}: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _itinerairesWithAgency = results;
        _isLoading = false;
        _isRefreshing = false;
      });

      if (results.isEmpty) {
        _errorMessage = 'Aucun itinéraire disponible pour cette recherche';
      }
    } catch (e) {
      debugPrint('Erreur lors de la recherche: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _isRefreshing = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $_errorMessage'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _fetchItinerairesWithAgencies();
  }

  // Méthode pour afficher le dialogue de sélection des départs
  Future<void> _showDeparturesDialog() async {
    await _fetchDepartures(); // Récupère les données avant d'afficher

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner un point de départ'),
        content: _loadingDepartures
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _departuresList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_departuresList[index]),
                onTap: () {
                  Navigator.pop(context);
                  // Vous pouvez ajouter ici la logique pour mettre à jour le départ sélectionné
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Méthode pour afficher le dialogue de sélection des destinations
  Future<void> _showDestinationsDialog() async {
    await _fetchDestinations(); // Récupère les données avant d'afficher

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner une destination'),
        content: _loadingDestinations
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _destinationsList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_destinationsList[index]),
                onTap: () {
                  Navigator.pop(context);
                  // Vous pouvez ajouter ici la logique pour mettre à jour la destination sélectionnée
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinéraires disponibles',
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
          // Bouton pour sélectionner un départ
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _showDeparturesDialog,
            tooltip: 'Choisir un départ',
          ),
          // Bouton pour sélectionner une destination
          IconButton(
            icon: const Icon(Icons.location_city),
            onPressed: _showDestinationsDialog,
            tooltip: 'Choisir une destination',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchSummary(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: _isLoading
                ? _buildLoadingIndicator()
                : _hasError
                ? _buildErrorWidget()
                : _itinerairesWithAgency.isEmpty
                ? _buildEmptyState()
                : _buildItinerairesList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: Colors.blueGrey, size: 20),
              const SizedBox(width: 8),
              Text(
                '${widget.departure} → ${widget.destination}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (widget.dateAller != null || widget.heureAller != null || widget.agency != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (widget.dateAller != null)
                    _buildFilterChip(Icons.calendar_today, widget.dateAller!),
                  if (widget.heureAller != null)
                    _buildFilterChip(Icons.access_time, widget.heureAller!),
                  if (widget.agency != null)
                    _buildFilterChip(Icons.business, widget.agency!),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.blueGrey),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey[100],
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Recherche en cours...',
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
          const Text('Erreur lors de la recherche',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(_errorMessage.isNotEmpty ? _errorMessage : 'Une erreur est survenue',
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
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Aucun itinéraire disponible',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Aucun itinéraire correspondant à votre recherche n\'a été trouvé. Essayez de modifier vos critères.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Modifier la recherche'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D56F0),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItinerairesList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _itinerairesWithAgency.length,
      itemBuilder: (context, index) {
        final item = _itinerairesWithAgency[index];
        return _buildItineraireCard(item);
      },
    );
  }

  Widget _buildItineraireCard(Map<String, dynamic> item) {
    final itineraire = item['itineraireData'] ?? {};
    final agence = item['agence'] ?? {};

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToVoyages(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Logo de l'agence
                  Container(
                    width: 48,
                    height: 48,
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
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.business, size: 24),
                      ),
                    )
                        : const Icon(Icons.business, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agence['nom']?.toString() ?? 'Agence inconnue',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber[600], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              (agence['note'] as num?)?.toStringAsFixed(1) ?? 'N/A',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.phone, color: Colors.grey[500], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              agence['telephone']?.toString() ?? '--',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Détails de l'itinéraire
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itineraire['departure']?.toString() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Départ: ${itineraire['heureDepartDefaut'] ?? '--:--'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${((itineraire['duree'] as num? ?? 0) / 60 )} h',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          itineraire['destination']?.toString() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Arrivée: ${itineraire['heureArriveeDefaut'] ?? '--:--'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Prix et bouton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'À partir de ${itineraire['prixMin']?.toString() ?? '0'} FCFA',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Color(0xFF3D56F0)),
                      ),
                      Text(
                        '${itineraire['nombreVoyages']?.toString() ?? '0'} départs par jour',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _navigateToVoyages(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D56F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Voir les horaires',
                        style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToVoyages(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoyagesListPage(
          itineraireId: item['itineraireId'] as String?,
          itineraireData: item['itineraireData'] as Map<String, dynamic>?,
          agenceData: item['agence'] as Map<String, dynamic>?,
          agenceId: item['agenceId'] as String?,
          dateAller: widget.dateAller,
          heureAller: widget.heureAller,
          agency: widget.agency,
        ),
      ),
    );
  }
}