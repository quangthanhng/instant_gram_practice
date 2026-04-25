import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gap/gap.dart';
import 'package:instagram_clone_qthanh/stat/auth/backend/authenticator.dart';
import 'firebase_options.dart';
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueGrey,
        tabBarTheme: TabBarThemeData(indicatorColor: Colors.blueGrey),
      ),
      themeMode: ThemeMode.dark,
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        // backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              final result = await Authenticator().loginWithGoogle();
              result.log();
            },
            child: const Text('Sign In With Google'),
          ),
          Gap(20),
          TextButton(
            onPressed: () async {
              final result = await Authenticator().loginWithFacebook();
              result.log();
            },
            child: const Text('Sign In With Facebook'),
          ),
        ],
      ),
    );
  }
}
