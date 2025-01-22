import 'package:flutter/material.dart';
import 'package:go_express/Screens/settings_page.dart';
import 'package:go_express/Screens/travel_details_screen.dart';
import 'notificationPage.dart';


class TravelInfo {
  final String agencyName;
  final String departure;
  final String destination;
  final String time;
  final String imageAsset;

  TravelInfo({
    required this.agencyName,
    required this.departure,
    required this.destination,
    required this.time,
    required this.imageAsset,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<TravelInfo> allTravels = [];
  List<TravelInfo> filteredTravels = [];

  @override
  void initState() {
    super.initState();
    allTravels = [
      TravelInfo(
        agencyName: "Touristique Express",
        departure: "Yaoundé",
        destination: "Douala",
        time: "10h30",
        imageAsset: "assets/images/bus1.jpeg",
      ),
      TravelInfo(
        agencyName: "Bucar Voyage",
        departure: "Yaoundé",
        destination: "Baffoussam",
        time: "8h30",
        imageAsset: "assets/images/bus2.jpeg",
      ),
      TravelInfo(
        agencyName: "General Express Voyage",
        departure: "Yaoundé",
        destination: "Douala",
        time: "11h20",
        imageAsset: "assets/images/bus3.jpeg",
      ),
      TravelInfo(
        agencyName: "International Line",
        departure: "Yaoundé",
        destination: "Bertoa",
        time: "9h20",
        imageAsset: "assets/images/bus1.jpeg",
      ),
    ];
    filteredTravels = List.from(allTravels);
  }

  void _filterTravels(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTravels = List.from(allTravels);
      } else {
        filteredTravels = allTravels.where((travel) {
          return travel.agencyName.toLowerCase().contains(query.toLowerCase()) ||
              travel.departure.toLowerCase().contains(query.toLowerCase()) ||
              travel.destination.toLowerCase().contains(query.toLowerCase()) ||
              travel.time.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToDetails(TravelInfo travel) {
    TravelDetails travelDetails = TravelDetails(
      agency: travel.agencyName,
      destination: travel.destination,
      departurePlace: travel.departure,
      time: travel.time,
      totalSeats: 50,
      availableSeats: 20,
      regularPrice: 6000,
      vipPrice: 7500,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TravelDetailsScreen(travelDetails: travelDetails),
      ),
    );
  }

  Widget _buildTravelCard(TravelInfo travel) {
    return InkWell(
      onTap: () => _navigateToDetails(travel),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  travel.imageAsset,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      travel.agencyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D56F0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${travel.departure} - ${travel.destination}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Départ: ${travel.time}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu), // Icône hamburger
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec image de fond et logo
          Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/busFondBon.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 200, // Agrandir le logo
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTravels,
              decoration: InputDecoration(
                hintText: 'Rechercher un voyage...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3D56F0)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12), // Espacement entre la barre de recherche et les cartes
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                itemCount: filteredTravels.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final travel = filteredTravels[index];
                  return _buildTravelCard(travel);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}