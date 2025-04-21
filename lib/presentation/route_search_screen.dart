import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_scaffold.dart';
import '../core/provider/provider.dart';
import '../core/theme/AppliColors.dart';
import 'busRoute.dart'; // Assurez-vous que le chemin est correct
import '../data/models/routeModel.dart'; // Importez votre RouteModel

class RouteSearchResultScreen extends ConsumerWidget {
  final String departure;
  final String destination;

  const RouteSearchResultScreen({
    Key? key,
    required this.departure,
    required this.destination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routeSearchProvider);

    return AppScaffold(
      title: 'Résultats de recherche',
      body: routes.isEmpty
          ? Center(child: Text('Aucun trajet trouvé'))
          : ListView.builder(
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final routeModel = routes[index] as RouteModel;
          final route = BusRoute.fromRouteModel(routeModel);
          return RouteSearchCard(route: route);
        },
      ),
    );
  }
}

class RouteSearchCard extends StatelessWidget {
  final BusRoute route;

  const RouteSearchCard({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${route.departure} → ${route.destination}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  route.isVipRoute ? 'VIP' : 'Standard',
                  style: TextStyle(
                    color: route.isVipRoute
                        ? AppColors.primaryDark
                        : AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${route.departureTime.day}/${route.departureTime.month}/${route.departureTime.year}',
                  style: TextStyle(color: AppColors.textLight),
                ),
                Text(
                  'Heure: ${route.departureTime.hour}:${route.departureTime.minute}',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Places disponibles: ${route.availableSeats}',
                  style: TextStyle(color: AppColors.text),
                ),
                Text(
                  'Prix: ${route.price.toStringAsFixed(2)} FCFA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // TODO: Naviguer vers l'écran de réservation
              },
              child: Text('Réserver'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}