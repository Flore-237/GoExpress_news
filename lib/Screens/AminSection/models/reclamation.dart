
class Reclamation {
  String id;
  String clientName;
  String clientEmail;
  String description;
  String statut;
  List<String> commentaires;

  Reclamation({
    this.id = '',
    required this.clientName,
    required this.clientEmail,
    required this.description,
    this.statut = 'Ouvert',
    this.commentaires = const [],
  });

  // Convertir de Firestore à Reclamation
  factory Reclamation.fromMap(Map<String, dynamic> data, String id) {
    return Reclamation(
      id: id,
      clientName: data['clientName'] ?? '',
      clientEmail: data['clientEmail'] ?? '',
      description: data['description'] ?? '',
      statut: data['statut'] ?? 'Ouvert',
      commentaires: List<String>.from(data['commentaires'] ?? []),
    );
  }

  // Convertir de Reclamation à Firestore
  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'clientEmail': clientEmail,
      'description': description,
      'statut': statut,
      'commentaires': commentaires,
    };
  }
}