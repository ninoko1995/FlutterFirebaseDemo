import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:photoapp/sign_in_screen.dart';
import 'package:photoapp/photo_list_screen.dart';
import 'package:photoapp/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
      ProviderScope(
        child: MyApp()
      ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer(builder: (context, watch, child) {
        final asyncUser = watch(userProvider);

        return asyncUser.when(
          data: (User? data) {
            return data == null ? SignInScreen() : PhotoListScreen();
          },
          loading: () {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          error: (e, stackTrace) {
            return Scaffold(
              body: Center(
                child: Text(e.toString()),
              ),
            );
          },
        );
      }),
    );
  }
}