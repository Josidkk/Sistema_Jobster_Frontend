import 'package:flutter/material.dart';
import 'screen/pre-login.dart';
import 'screen/publicarPlazaScreen.dart';
import 'screen/perfilScreen.dart';
import 'services/navigation_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 77, 18),
        ),
      ),
      home: const prelogin(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Inicio')),
    const PublicarPlazaScreen(),
    const PerfilScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Esto elimina el botón de regreso
        flexibleSpace: Container(
   decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFF6B00), Color(0xFFEE4D00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
),
        title: Row(
          children: [
            Image.asset('assets/Jobster_logo_largo.png', height: 45,width: 140 ,),            
          ],
        ),
        actions: [          IconButton(
            icon: const Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: () {
             
              NavigationService.navigateWithFade(
                context,
                const prelogin(), 
              );

              // Otra opción sería usando pushReplacement para salir completamente
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => prelogin()),
              // );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (Widget child, Animation<double> animation) {
    return FadeTransition(opacity: animation, child: child);
  },
  child: _pages[_selectedIndex],
),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 107, 0),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.control_point,size: 35,), label: 'Publicar'),
          // BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
