import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proximity/repositories/mock_trip_repository.dart';
import 'package:proximity/repositories/trip_repository.dart';
import 'package:proximity/ui/trip/places_of_interest_screen.dart';
import 'package:proximity/ui/trips_list/trips_list_screen.dart';
import 'package:proximity/ui/trips_list/trips_list_viewmodel.dart';

void main() {
  runApp(const ProximityApp());
}

// Define route names as constants for type safety
class AppRoutes {
  static const String trips = '/';
  static const String places = 'trip/:tripId';
  
  static String placesRoute(String tripId) => '/trip/$tripId';
}

class ProximityApp extends StatelessWidget {
  const ProximityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TripRepository>(create: (context) => MockTripRepository()),
      ],
      builder: (context, child) {
        final GoRouter router = GoRouter(
          initialLocation: AppRoutes.trips,
          routes: [
        GoRoute(
          path: AppRoutes.trips,
          builder: (context, state) {
                final viewModel = TripsListViewModel(context.read());
            viewModel.load();
            return TripsScreen(viewModel: viewModel);
          },
              routes: [
            GoRoute(
              path: AppRoutes.places,
              builder: (context, state) {
                final tripId = state.pathParameters['tripId']!;
                    return PlacesOfInterestScreen(tripId: tripId);
              },
                ),
              ],
            ),
          ],
        );

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              surface: const Color(0xFFECF5F5),
            ),
          ),
          routerConfig: router,
        );
      },
    );
  }
}
