class PaymentIntentModel {
  final String id;
  final String? clientSecret;
  final int amount;
  final String currency;
  final String status;

  PaymentIntentModel({
    required this.id,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) {
    return PaymentIntentModel(
      id: json['id'],
      clientSecret: json['client_secret'],
      amount: json['amount'],
      currency: json['currency'],
      status: json['status'],
    );
  }
}

class PaymentRecord {
  final String userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final String paymentIntentId;

  PaymentRecord({
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.paymentIntentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paymentIntentId': paymentIntentId,
    };
  }
}