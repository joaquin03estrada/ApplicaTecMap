import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'viewmodels/NewsViewModel.dart'; 
import 'views/Map.dart';
import 'views/News.dart';
import 'helpers/NewsHelper.dart';
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1b3a6b)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _Destination {
  final String label;
  final IconData icon;
  final Widget screen;
  const _Destination(this.label, this.icon, this.screen);
}

final List<_Destination> _destinations = [
  _Destination('Mapa',     Icons.map,       Map()),
  const _Destination('Noticias', Icons.newspaper, News()),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          for (final d in _destinations) d.screen,
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}