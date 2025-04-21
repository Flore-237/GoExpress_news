class Agency {
  String id;
  String agencyName;
  String departure;
  String departureTime;
  String departureDate;
  String seatType;
  String destination;
  String seats;
  String imageUrl;
  String pricing;

  Agency({
    required this.id,
    required this.agencyName,
    required this.departure,
    required this.departureTime,
    required this.departureDate,
    required this.seatType,
    required this.destination,
    required this.seats,
    required this.pricing,
    required this.imageUrl, required String name, required String logoUrl, required String bannerUrl, required String description, required String contactPhone, required String contactEmail, required List<String> routes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agencyName': agencyName,
      'departure': departure,
      'departureTime': departureTime,
      'departureDate': departureDate,
      'seatType': seatType,
      'destination': destination,
      'seats': seats,
      'imageUrl': imageUrl,
    };
  }

  factory Agency.fromMap(Map<String, dynamic> map) {
    return Agency(
      id: map['id'],
      agencyName: map['agencyName'],
      departure: map['departure'],
      departureTime: map['departureTime'],
      departureDate: map['departureDate'],
      seatType: map['seatType'],
      destination: map['destination'],
      seats: map['seats'],
      imageUrl: map['imageUrl'], name: '', logoUrl: '', bannerUrl: '', description: '', contactPhone: '', contactEmail: '', routes: [], pricing: '',
    );
  }
}