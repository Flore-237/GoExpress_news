import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialisation de Stripe
  static void initializeStripe() {
    Stripe.publishableKey = 'your_publishable_key';
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    Stripe.urlScheme = 'flutterstripe';
  }

  // Paiement mobile money
  Future<bool> processMobilePayment({
    required String paymentMethod,
    required String phoneNumber,
    required double amount,
    required String reservationId,
  }) async {
    try {
      // Simulation de paiement
      await Future.delayed(const Duration(seconds: 2));

      // Enregistrement du paiement dans Firestore
      await _firestore.collection('payments').add({
        'userId': _auth.currentUser?.uid,
        'paymentMethod': paymentMethod,
        'phoneNumber': phoneNumber,
        'amount': amount,
        'reservationId': reservationId,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Erreur de paiement: $e');
      return false;
    }
  }

  // Paiement par carte bancaire (corrigé)
  Future<PaymentResult> processCardPayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> cardDetails,
  }) async {
    try {
      // 1. Créer l'intention de paiement
      final intent = await _createPaymentIntent(
        amount: amount,
        currency: currency,
      );

      // 2. Créer la méthode de paiement
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: _auth.currentUser?.email,
              phone: _auth.currentUser?.phoneNumber,
              name: cardDetails['cardHolderName'],
            ),
          ),
        ),
      );


      // 4. Enregistrer la transaction
      await _savePaymentRecord(
        amount: amount,
        currency: currency,
        paymentMethod: 'card',
        paymentIntentId: intent['id'],
      );

      return PaymentResult.success();
    } catch (e) {
      return PaymentResult.failed(e.toString());
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    final response = await http.post(
      Uri.parse('https://your-api-endpoint/create-payment-intent'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _auth.currentUser?.getIdToken()}',
      },
      body: json.encode({
        'amount': (amount * 100).toInt(),
        'currency': currency,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create payment intent');
    }
  }

  Future<void> _savePaymentRecord({
    required double amount,
    required String currency,
    required String paymentMethod,
    required String paymentIntentId,
  }) async {
    await _firestore.collection('payments').add({
      'userId': _auth.currentUser?.uid,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentIntentId': paymentIntentId,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

class PaymentResult {
  final bool success;
  final String? error;

  PaymentResult.success() : success = true, error = null;
  PaymentResult.failed(this.error) : success = false;
}
