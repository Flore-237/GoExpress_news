import 'package:flutter_riverpod/flutter_riverpod.dart';

class HorairesProvider extends StateNotifier<List<Horaire>> {
  final HorairesService _service;
  final String _agenceId;

  HorairesProvider(this._service, this._agenceId) : super([]);

  Future<void> fetchHoraires() async {
    try {
      state = await _service.getHorairesByAgence(_agenceId);
    } catch (e) {
      state = []; // Reset to empty list on error
      rethrow;
    }
  }

  Future<void> addHoraire(Horaire newHoraire) async {
    try {
      final createdHoraire = await _service.createHoraire(
        agenceId: _agenceId,
        depart: newHoraire.depart,
        destination: newHoraire.destination,
        heureDepart: newHoraire.heureDepart,
        placesDisponibles: newHoraire.nombrePlacesDisponibles,
      );

      state = [...state, createdHoraire];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHoraire(String horaireId) async {
    try {
      await _service.deleteHoraire(horaireId);
      state = state.where((h) => h.id != horaireId).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHoraire(Horaire updatedHoraire) async {
    try {
      final result = await _service.updateHoraire(
        horaireId: updatedHoraire.id,
        depart: updatedHoraire.depart,
        destination: updatedHoraire.destination,
        heureDepart: updatedHoraire.heureDepart,
        placesDisponibles: updatedHoraire.nombrePlacesDisponibles,
      );

      state = state.map((h) => h.id == result.id ? result : h).toList();
    } catch (e) {
      rethrow;
    }
  }
}

// Service class that would handle the actual API calls
class HorairesService {
  Future<List<Horaire>> getHorairesByAgence(String agenceId) async {
    // Implement your API call here
    // Example:
    // final response = await http.get(Uri.parse('$apiUrl/agences/$agenceId/horaires'));
    // return Horaire.fromJsonList(response.body);

    // Mock data for demonstration:
    await Future.delayed(const Duration(seconds: 1));
    return [
      Horaire(
        id: '1',
        depart: 'Paris',
        destination: 'Lyon',
        heureDepart: '08:00',
        nombrePlacesDisponibles: 20,
        agenceId: agenceId,
      ),
      Horaire(
        id: '2',
        depart: 'Lyon',
        destination: 'Marseille',
        heureDepart: '12:30',
        nombrePlacesDisponibles: 15,
        agenceId: agenceId,
      ),
    ];
  }

  Future<Horaire> createHoraire({
    required String agenceId,
    required String depart,
    required String destination,
    required String heureDepart,
    required int placesDisponibles,
  }) async {
    // Implement your API call here
    await Future.delayed(const Duration(seconds: 1));

    return Horaire(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      depart: depart,
      destination: destination,
      heureDepart: heureDepart,
      nombrePlacesDisponibles: placesDisponibles,
      agenceId: agenceId,
    );
  }

  Future<void> deleteHoraire(String horaireId) async {
    // Implement your API call here
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<Horaire> updateHoraire({
    required String horaireId,
    required String depart,
    required String destination,
    required String heureDepart,
    required int placesDisponibles,
  }) async {
    // Implement your API call here
    await Future.delayed(const Duration(seconds: 1));

    return Horaire(
      id: horaireId,
      depart: depart,
      destination: destination,
      heureDepart: heureDepart,
      nombrePlacesDisponibles: placesDisponibles,
      agenceId: '', // This would be filled from existing data
    );
  }
}

// Horaire model class
class Horaire {
  final String id;
  final String depart;
  final String destination;
  final String heureDepart;
  final int nombrePlacesDisponibles;
  final String agenceId;

  Horaire({
    required this.id,
    required this.depart,
    required this.destination,
    required this.heureDepart,
    required this.nombrePlacesDisponibles,
    required this.agenceId,
  });

  // Optionally add fromJson/toJson methods if needed
  factory Horaire.fromJson(Map<String, dynamic> json) {
    return Horaire(
      id: json['id'],
      depart: json['depart'],
      destination: json['destination'],
      heureDepart: json['heureDepart'],
      nombrePlacesDisponibles: json['nombrePlacesDisponibles'],
      agenceId: json['agenceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'depart': depart,
      'destination': destination,
      'heureDepart': heureDepart,
      'nombrePlacesDisponibles': nombrePlacesDisponibles,
      'agenceId': agenceId,
    };
  }
}

// Provider declaration (should be in a separate providers.dart file)
final horairesProvider = StateNotifierProvider.autoDispose.family<HorairesProvider, List<Horaire>, String>(
      (ref, agenceId) {
    final service = HorairesService();
    return HorairesProvider(service, agenceId);
  },
);