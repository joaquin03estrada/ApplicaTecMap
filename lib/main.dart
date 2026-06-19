import 'package:flutter/material.dart';
import 'views/Map.dart';
import 'views/News.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff1b3a6b)),
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

const List<_Destination> _destinations = [
  _Destination('Mapa',     Icons.map,       Map()),
  _Destination('Noticias', Icons.newspaper, News()),
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
      appBar: AppBar(
        title: Text(_destinations[_selectedIndex].label, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff1b3a6b),
      ),
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