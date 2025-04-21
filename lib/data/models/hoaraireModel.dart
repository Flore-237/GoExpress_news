class Horaire {
  final String id;
  final String agenceId;
  final String depart;
  final String destination;
  final DateTime heureDepart;
  final DateTime heureArrivee;
  final int nombrePlacesDisponibles;

  Horaire({
    required this.id,
    required this.agenceId,
    required this.depart,
    required this.destination,
    required this.heureDepart,
    required this.heureArrivee,
    required this.nombrePlacesDisponibles,
  });

  factory Horaire.fromJson(Map<String, dynamic> json) {
    return Horaire(
      id: json['id'],
      agenceId: json['agenceId'],
      depart: json['depart'],
      destination: json['destination'],
      heureDepart: DateTime.parse(json['heureDepart']),
      heureArrivee: DateTime.parse(json['heureArrivee']),
      nombrePlacesDisponibles: json['nombrePlacesDisponibles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agenceId': agenceId,
      'depart': depart,
      'destination': destination,
      'heureDepart': heureDepart.toIso8601String(),
      'heureArrivee': heureArrivee.toIso8601String(),
      'nombrePlacesDisponibles': nombrePlacesDisponibles,
    };
  }
}