import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/models/agenceModel.dart';
import '../data/repositories/agenceRepositorie.dart';
import 'editAgence_screen.dart';

class AgencyDetailsScreen extends StatefulWidget {
  final String agencyId;

  const AgencyDetailsScreen({Key? key, required this.agencyId, required AgencyModel agency}) : super(key: key);

  @override
  State<AgencyDetailsScreen> createState() => _AgencyDetailsScreenState();
}

class _AgencyDetailsScreenState extends State<AgencyDetailsScreen> {
  late Future<AgencyModel?> _agencyFuture;
  final AgencyRepository _agencyRepository = AgencyRepository();

  @override
  void initState() {
    super.initState();
    _agencyFuture = _agencyRepository.getAgencyById(widget.agencyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'agence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
          ),
        ],
      ),
      body: FutureBuilder<AgencyModel?>(
        future: _agencyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Impossible de charger les détails de l\'agence'));
          }

          final agency = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Logo et Nom
                _buildHeaderSection(agency),
                const SizedBox(height: 24),

                // Section Description
                _buildDescriptionSection(agency),
                const SizedBox(height: 24),

                // Section Contact
                _buildContactSection(agency),
                const SizedBox(height: 24),

                // Section Routes
                _buildRoutesSection(agency),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAgencyScreen(agencyId: widget.agencyId),
      ),
    );
  }

  Widget _buildHeaderSection(AgencyModel agency) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo avec placeholder si null
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: agency.safeLogoUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: const Icon(Icons.business, size: 50),
            ),
            errorWidget: (context, url, error) => Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, size: 50),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            agency.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(AgencyModel agency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      'Description',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(height: 8),
    Text(
    agency.description,
    style: Theme.of(context).textTheme
        .bodyMedium,
    ),
      ],
    );
  }

  Widget _buildContactSection(AgencyModel agency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildContactInfo(
          icon: Icons.phone,
          value: agency.contactPhone,
          onTap: () => _launchPhoneCall(agency.contactPhone),
        ),
        const SizedBox(height: 8),
        _buildContactInfo(
          icon: Icons.email,
          value: agency.contactEmail,
          onTap: () => _launchEmail(agency.contactEmail),
        ),
      ],
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildRoutesSection(AgencyModel agency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Routes desservies',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (agency.supportedRoutes.isEmpty)
          Text(
            'Aucune route disponible',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: agency.supportedRoutes
                .map((route) => Chip(
              label: Text(route),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ))
                .toList(),
          ),
      ],
    );
  }

  void _launchPhoneCall(String phoneNumber) {
    // Implémentez la logique pour passer un appel
    debugPrint('Appel vers $phoneNumber');
  }

  void _launchEmail(String email) {
    // Implémentez la logique pour envoyer un email
    debugPrint('Email à $email');
  }
}