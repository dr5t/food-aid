import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/donation_provider.dart';
import 'providers/emergency_provider.dart';
import 'providers/logistics_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/connection_provider.dart';
import 'services/firestore_service.dart';
// import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestoreService = FirestoreService();
  // Seeding is now handled dynamically in AuthProvider/AuthService during sign-in
  // to prevent blocking the app startup sequence.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => DonationProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => EmergencyProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => LogisticsProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(firestoreService),
        ),
      ],
      child: const FoodAidApp(),
    ),
  );
}
