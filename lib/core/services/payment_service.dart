import 'package:cloud_functions/cloud_functions.dart';
import '../../shared/models/booking.dart';

class PaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
    required String phoneNumber,
  }) async {
    try {
      final result = await _functions.httpsCallable('initiatePayment').call({
        'bookingId': bookingId,
        'method': method.toString(),
        'amount': amount,
        'phoneNumber': phoneNumber,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw _handlePaymentException(e);
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String bookingId,
    required String transactionId,
  }) async {
    try {
      final result = await _functions.httpsCallable('verifyPayment').call({
        'bookingId': bookingId,
        'transactionId': transactionId,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw _handlePaymentException(e);
    }
  }

  Exception _handlePaymentException(dynamic e) {
    if (e is FirebaseFunctionsException) {
      switch (e.code) {
        case 'invalid-phone':
          return Exception('Numéro de téléphone invalide');
        case 'insufficient-funds':
          return Exception('Solde insuffisant');
        case 'payment-failed':
          return Exception('Le paiement a échoué');
        case 'invalid-amount':
          return Exception('Montant invalide');
        default:
          return Exception('Erreur de paiement: ${e.message}');
      }
    }
    return Exception('Une erreur inattendue est survenue lors du paiement');
  }
}
