import 'package:busexpress/presentation/route_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_scaffold.dart';
import '../core/provider/provider.dart';

class RouteSearchResultScreen extends ConsumerWidget {
  final String departure;
  final String destination;

  const RouteSearchResultScreen({
    Key? key,
    required this.departure,
    required this.destination,
  }) : super(key: key);

  get busRoute => null;

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
          final routeModel = routes[index];
          return RouteSearchCard(route: busRoute);
        },
      ),
    );
  }
}