import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

interface PaymentRequest {
  bookingId: string;
  method: string;
  amount: number;
  phoneNumber: string;
}

interface PaymentVerification {
  bookingId: string;
  transactionId: string;
}

export const initiatePayment = functions.https.onCall(async (data: PaymentRequest, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'The function must be called while authenticated.'
    );
  }

  const { bookingId, method, amount, phoneNumber } = data;

  try {
    // Vérifier si la réservation existe
    const bookingRef = admin.firestore().collection('bookings').doc(bookingId);
    const booking = await bookingRef.get();

    if (!booking.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Booking not found'
      );
    }

    // Simuler l'intégration avec le service de paiement mobile
    // En production, ceci serait remplacé par l'API réelle du service de paiement
    const transactionId = `TXN${Date.now()}${Math.floor(Math.random() * 1000)}`;
    const ticketNumber = `TKT${Date.now()}${Math.floor(Math.random() * 1000)}`;

    // En production, nous attendrions la confirmation du service de paiement
    // Pour ce prototype, nous simulons une réponse réussie
    return {
      success: true,
      transactionId,
      ticketNumber,
      message: `Un message de confirmation a été envoyé au ${phoneNumber}`,
    };
  } catch (error) {
    console.error('Payment initiation error:', error);
    throw new functions.https.HttpsError(
      'internal',
      'An error occurred while processing the payment'
    );
  }
});

export const verifyPayment = functions.https.onCall(async (data: PaymentVerification, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'The function must be called while authenticated.'
    );
  }

  const { bookingId, transactionId } = data;

  try {
    // Vérifier si la réservation existe
    const bookingRef = admin.firestore().collection('bookings').doc(bookingId);
    const booking = await bookingRef.get();

    if (!booking.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Booking not found'
      );
    }

    // En production, nous vérifierions le statut auprès du service de paiement
    // Pour ce prototype, nous simulons une vérification réussie
    const isPaymentConfirmed = true;

    if (isPaymentConfirmed) {
      // Mettre à jour le statut de la réservation
      await bookingRef.update({
        status: 'confirmed',
        paymentReference: transactionId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Envoyer une notification au client
      const booking = await bookingRef.get();
      const bookingData = booking.data();
      
      if (bookingData?.userId) {
        const userRef = admin.firestore().collection('users').doc(bookingData.userId);
        const user = await userRef.get();
        const userData = user.data();

        if (userData?.fcmToken) {
          await admin.messaging().send({
            token: userData.fcmToken,
            notification: {
              title: 'Paiement confirmé',
              body: 'Votre réservation a été confirmée. Vous pouvez maintenant télécharger votre billet.',
            },
            data: {
              type: 'BOOKING_CONFIRMED',
              bookingId,
            },
          });
        }
      }

      return {
        success: true,
        message: 'Payment verified successfully',
      };
    } else {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Payment verification failed'
      );
    }
  } catch (error) {
    console.error('Payment verification error:', error);
    throw new functions.https.HttpsError(
      'internal',
      'An error occurred while verifying the payment'
    );
  }
});

// Trigger when a new booking is created
export const onBookingCreated = functions.firestore
  .document('bookings/{bookingId}')
  .onCreate(async (snap, context) => {
    const booking = snap.data();
    const userId = booking.userId;

    try {
      // Get user's FCM token
      const userRef = admin.firestore().collection('users').doc(userId);
      const user = await userRef.get();
      const userData = user.data();

      if (userData?.fcmToken) {
        // Send notification to user
        await admin.messaging().send({
          token: userData.fcmToken,
          notification: {
            title: 'Nouvelle réservation',
            body: 'Votre réservation a été créée avec succès. Veuillez procéder au paiement.',
          },
          data: {
            type: 'BOOKING_CREATED',
            bookingId: context.params.bookingId,
          },
        });
      }
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });
