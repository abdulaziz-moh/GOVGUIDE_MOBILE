import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:govguide/app/app.dart';
import 'package:govguide/auth/auth_provider.dart';
import 'package:govguide/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          AuthProvider(), // (_) => AuthProvider(), also possible because the parameter is unused
      child: const GovGuideApp(),
    ),
  );
}
