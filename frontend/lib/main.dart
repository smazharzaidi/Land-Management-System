import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UI/DashboardScreen.dart'; // Adjust the import paths as necessary
import 'Functionality/SignInAuth.dart'; // Adjust the import paths as necessary
import 'Functionality/NFTListProvider.dart'; // Adjust the import paths as necessary
import 'UI/SignInScreen.dart'; // Adjust the import paths as necessary

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AuthServiceLogin _authService = AuthServiceLogin();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NFTListProvider()),
        // Add other providers here as needed
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Land Management Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder<bool>(
          future: _authService.isTokenValidAndNotExpired(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == true) {
                return DashboardScreen(
                  authService: _authService,
                );
              }
              return SignInScreen();
            }
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        ),
      ),
    );
  }
}
