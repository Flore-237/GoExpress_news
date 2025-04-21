import 'package:flutter/material.dart';
import '../data/models/ticketModel.dart';
import '../data/service/agenceService.dart';
import 'bookingReservation_scree.dart';
import 'busRoute.dart';

class SearchResultsScreen extends StatefulWidget {
  final String departure;
  final String destination;
  final String? date;
  final String? time;

  const SearchResultsScreen({
    Key? key,
    required this.departure,
    required this.destination,
    this.date,
    this.time, String? dateAller, String? heureAller,
  }) : super(key: key);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final AgencyService _agencyService = AgencyService();
  List<TripModel> _trips = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchTrips();
  }

  Future<void> _searchTrips() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      DateTime? searchDate = widget.date != null
          ? DateTime.tryParse(widget.date!)
          : null;

      final trips = await _agencyService.searchTrips(
          departure: widget.departure,
          destination: widget.destination,
          date: searchDate,
      );

      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les voyages';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats: ${widget.departure} → ${widget.destination}'),
        backgroundColor: const Color(0xFF3D56F0),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3D56F0),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchTrips,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bus_outlined,
              color: Colors.grey,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun voyage trouvé pour ${widget.departure} → ${widget.destination}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _trips.length,
      itemBuilder: (context, index) {
        final trip = _trips[index];
        return _buildTripCard(trip);
      },
    );
  }

  Widget _buildTripCard(TripModel trip) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${trip.departure} → ${trip.destination}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${trip.price.toStringAsFixed(2)} FCFA',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D56F0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  trip.departureTime.toString().substring(0, 16),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Places disponibles: ${trip.availableSeats}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                Text(
                  'Type: ${trip.busType}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToBooking(trip),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D56F0),
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Réserver'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBooking(TripModel trip) {
    BusRoute route = BusRoute.fromTripModel(trip);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(route: route),
      ),
    );
  }
}