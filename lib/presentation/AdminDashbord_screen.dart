import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAgence = ref.watch(currentAgenceProvider); // Assume this provider exists

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Administrateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context, currentAgence),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, currentAgence),
            const SizedBox(height: 24),
            _buildStatsRow(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Agence? agence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenue, Administrateur',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          agence?.name ?? 'Agence non sélectionnée',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Dernière connexion: ${DateTime.now().toString()}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              context: context,
              value: '24',
              label: 'Voyages aujourd\'hui',
              icon: Icons.directions_bus,
            ),
            _StatItem(
              context: context,
              value: '156',
              label: 'Réservations',
              icon: Icons.confirmation_number,
            ),
            _StatItem(
              context: context,
              value: '92%',
              label: 'Taux de remplissage',
              icon: Icons.percent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _QuickActionCard(
              context: context,
              icon: Icons.people,
              label: 'Gérer les conducteurs',
              onTap: () => _navigateToDriversManagement(context),
            ),
            _QuickActionCard(
              context: context,
              icon: Icons.bus_alert,
              label: 'Gérer les véhicules',
              onTap: () => _navigateToVehiclesManagement(context),
            ),
            _QuickActionCard(
              context: context,
              icon: Icons.bar_chart,
              label: 'Voir les statistiques',
              onTap: () => _navigateToStatistics(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activité Récente',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _ActivityItem(
                  title: 'Nouveau conducteur ajouté',
                  time: 'Il y a 15 minutes',
                  icon: Icons.person_add,
                ),
                const Divider(),
                _ActivityItem(
                  title: 'Horaires mis à jour',
                  time: 'Il y a 2 heures',
                  icon: Icons.schedule,
                ),
                const Divider(),
                _ActivityItem(
                  title: 'Panne signalée sur le bus #23',
                  time: 'Il y a 5 heures',
                  icon: Icons.warning,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, Agence? agence) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  'Administrateur',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  agence?.name ?? 'Agence non sélectionnée',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Tableau de bord'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Gestion des horaires'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Gestion des conducteurs'),
            onTap: () => _navigateToDriversManagement(context),
          ),
          ListTile(
            leading: const Icon(Icons.directions_bus),
            title: const Text('Gestion des véhicules'),
            onTap: () => _navigateToVehiclesManagement(context),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistiques'),
            onTap: () => _navigateToStatistics(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () => _showSettings(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToDriversManagement(BuildContext context) {
    // Implement navigation to drivers management
  }

  void _navigateToVehiclesManagement(BuildContext context) {
    // Implement navigation to vehicles management
  }

  void _navigateToStatistics(BuildContext context) {
    // Implement navigation to statistics
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to notifications
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Sécurité'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to security
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Implement logout logic
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Supporting widget classes
class _StatItem extends StatelessWidget {
  final BuildContext context;
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.context,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.context,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const _ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(time),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

// Assume these model classes exist
class Agence {
  final String id;
  final String name;

  Agence({required this.id, required this.name});
}

// Assume this provider exists
final currentAgenceProvider = Provider<Agence?>((ref) {
  return Agence(id: 'current_agence_id', name: 'Mon Agence Principale');
});