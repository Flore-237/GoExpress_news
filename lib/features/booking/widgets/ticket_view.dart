import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ticket_service.dart';
import '../../../shared/models/agency.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/travel.dart';
import '../../../core/widgets/custom_button.dart';

class TicketView extends ConsumerStatefulWidget {
  final Booking booking;
  final Travel travel;
  final Agency agency;

  const TicketView({
    super.key,
    required this.booking,
    required this.travel,
    required this.agency,
  });

  @override
  ConsumerState<TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends ConsumerState<TicketView> {
  final _ticketService = TicketService();
  bool _isLoading = false;
  File? _ticketFile;

  Future<void> _generateTicket() async {
    setState(() => _isLoading = true);

    try {
      final file = await _ticketService.generateTicket(
        booking: widget.booking,
        travel: widget.travel,
        agency: widget.agency,
      );

      setState(() {
        _ticketFile = file;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareTicket() async {
    if (_ticketFile == null) {
      await _generateTicket();
    }

    if (_ticketFile != null) {
      await _ticketService.shareTicket(_ticketFile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.agency.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Billet N° ${widget.booking.ticketNumber}',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (widget.agency.logo.isNotEmpty)
                      Image.network(
                        widget.agency.logo,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.business),
                      ),
                  ],
                ),
                const Divider(height: 32),
                _buildInfoRow(
                  'Trajet',
                  '${widget.travel.departure} → ${widget.travel.destination}',
                ),
                _buildInfoRow(
                  'Date',
                  '${widget.travel.departureTime.day}/${widget.travel.departureTime.month}/${widget.travel.departureTime.year}',
                ),
                _buildInfoRow(
                  'Heure',
                  '${widget.travel.departureTime.hour}:${widget.travel.departureTime.minute.toString().padLeft(2, '0')}',
                ),
                _buildInfoRow(
                  'Classe',
                  widget.booking.travelClass.toString().split('.').last.toUpperCase(),
                ),
                _buildInfoRow(
                  'Bus N°',
                  widget.travel.busNumber,
                ),
                const Divider(height: 32),
                _buildInfoRow(
                  'Passager',
                  widget.booking.passengerInfo['fullName'],
                ),
                _buildInfoRow(
                  'Téléphone',
                  widget.booking.passengerInfo['phoneNumber'],
                ),
                const Divider(height: 32),
                _buildInfoRow(
                  'Montant',
                  '${widget.booking.amount.toStringAsFixed(0)} FCFA',
                ),
                _buildInfoRow(
                  'Référence',
                  widget.booking.paymentReference ?? '',
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: _isLoading ? null : _generateTicket,
                  isLoading: _isLoading,
                  text: 'Télécharger PDF',
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  onPressed: _isLoading ? null : _shareTicket,
                  text: 'Partager',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
