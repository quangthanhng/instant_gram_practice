import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/auth_state_provider.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/is_logged_in_provider.dart';
import 'package:instagram_clone_qthanh/views/components/loading/loading_screen.dart';
import 'firebase_options.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
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
      home: Consumer(
        builder: (context, ref, child) {
          final isLoggedIn = ref.watch(isLoggedInProvider);
          Log(isLoggedIn).log();
          if (isLoggedIn) {
            return MainView();
          } else {
            return LoginView();
          }
        },
      ),
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main View'),
        // backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer(
        builder: (_, ref, child) => TextButton(
          onPressed: () async {
            LoadingScreen.instance().show(
              context: context,
              text: 'Hello World',
            );
            await ref.read(authStateProvider.notifier).logOut();
          },
          child: Center(child: const Text('Log out')),
        ),
      ),
    );
  }
}

// for when you are not logged in
class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login View'),
        // backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: ref.read(authStateProvider.notifier).logInWithGoogle,
            child: const Text('Sign In With Google'),
          ),
          Gap(20),
          TextButton(
            onPressed: ref.read(authStateProvider.notifier).logInWithFacebook,
            child: const Text('Sign In With Facebook'),
          ),
        ],
      ),
    );
  }
}
