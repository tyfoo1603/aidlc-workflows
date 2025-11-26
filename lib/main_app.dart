import 'package:easy_app/core/config/app_config.dart';
import 'package:easy_app/core/config/environment.dart';
import 'package:easy_app/core/di/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  final Environment environment;
  
  const MyApp({
    super.key,
    required this.environment,
  });

  @override
  Widget build(BuildContext context) {
    final appConfig = getIt<AppConfig>();
    final router = getIt<GoRouter>();
    
    return MaterialApp.router(
      title: appConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routerConfig: router,
    );
  }
}

