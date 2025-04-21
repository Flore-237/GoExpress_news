import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/agency.dart';
import '../models/booking.dart';
import '../models/travel.dart';

class TicketService {
  Future<File> generateTicket({
    required Booking booking,
    required Travel travel,
    required Agency agency,
  }) async {
    final pdf = pw.Document();

    final logoImage = agency.logo.isNotEmpty
        ? await networkImage(agency.logo)
        : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (logoImage != null)
                    pw.Image(logoImage, width: 100),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Billet de voyage',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'N° ${booking.ticketNumber}',
                        style: const pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Informations de voyage',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildInfoRow('Agence', agency.name),
                    _buildInfoRow('Départ', travel.departure),
                    _buildInfoRow('Destination', travel.destination),
                    _buildInfoRow(
                      'Date et heure',
                      '${travel.departureTime.day}/${travel.departureTime.month}/${travel.departureTime.year} à ${travel.departureTime.hour}:${travel.departureTime.minute.toString().padLeft(2, '0')}',
                    ),
                    _buildInfoRow(
                      'Classe',
                      booking.travelClass.toString().split('.').last.toUpperCase(),
                    ),
                    _buildInfoRow('Bus N°', travel.busNumber),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Informations passager',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildInfoRow('Nom', booking.passengerInfo['fullName']),
                    _buildInfoRow('Téléphone', booking.passengerInfo['phoneNumber']),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Paiement',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildInfoRow('Montant', '${booking.amount.toStringAsFixed(0)} FCFA'),
                    _buildInfoRow(
                      'Mode de paiement',
                      booking.paymentMethod.toString().split('.').last.toUpperCase(),
                    ),
                    _buildInfoRow('Référence', booking.paymentReference ?? ''),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Text(
                'Ce billet est valable uniquement pour la date et l\'heure indiquées.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/ticket_${booking.ticketNumber}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<void> shareTicket(File ticketFile) async {
    await Share.shareXFiles(
      [XFile(ticketFile.path)],
      subject: 'Billet de voyage',
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
