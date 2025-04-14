import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proximity/repositories/mock_trip_repository.dart';
import 'package:proximity/repositories/trip_repository.dart';
import 'package:proximity/ui/trips_list/trips_list_screen.dart';
import 'package:proximity/ui/trips_list/trips_list_viewmodel.dart';

void main() {
  runApp(const ProximityApp());
}

class ProximityApp extends StatelessWidget {
  const ProximityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the repository first
        Provider<TripRepository>(create: (context) => MockTripRepository()),
      ],
      builder: (context, child) {
        var viewModel = TripsListViewModel(context.read());
        viewModel.load();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              surface: const Color(0xFFECF5F5),
            ),
          ),
          home: TripsScreen(viewModel: viewModel),
        );
      },
    );
  }
}
