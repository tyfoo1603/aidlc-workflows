import 'package:easy_app/core/config/environment.dart';
import 'package:easy_app/core/di/dependency_injection.dart';
import 'package:easy_app/main_app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await setupDependencyInjection(Environment.dev);

  // Run app
  runApp(const MyApp(environment: Environment.dev));
}
