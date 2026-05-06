import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/is_logged_in_provider.dart';
import 'package:instagram_clone_qthanh/state/providers/is_loading_providers.dart';
// import 'package:instagram_clone_qthanh/views/components/animations/data_not_found_animation_view.dart';
// import 'package:instagram_clone_qthanh/views/components/animations/empty_contents_with_text_animation_view.dart';
// import 'package:instagram_clone_qthanh/views/components/animations/error_animation_view.dart';
// import 'package:instagram_clone_qthanh/views/components/animations/loading_animation_view.dart';
// import 'package:instagram_clone_qthanh/views/components/animations/small_error_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/loading/loading_screen.dart';
import 'package:instagram_clone_qthanh/views/login/login_view.dart';
import 'package:instagram_clone_qthanh/views/main/main_view.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await Supabase.initialize(
  //   url: 'https://tlngonlmfosshjtwcczz.supabase.co',
  //   anonKey: 'sb_publishable_8lTIeZYShTF7fEkliZjPpw_t3lktwK7',
  // );
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
          // take care of display the loading screen

          ref.listen<bool>(isLoadingProvider, (_, isLoading) {
            if (isLoading) {
              LoadingScreen.instance().show(context: context);
            } else {
              LoadingScreen.instance().hide();
            }
          });
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
