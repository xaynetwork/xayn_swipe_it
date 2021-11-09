import 'package:flutter/material.dart';
import 'package:xayn_swipe_it_example/repository/dog_repository.dart';

import 'pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swipe my Doggo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.red,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black12.withOpacity(0.6),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            elevation: 0.5,
          )),
      home: const Home(dogRepository: DogRepository()),
    );
  }
}
