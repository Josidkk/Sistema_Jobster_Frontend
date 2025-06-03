import 'package:flutter/material.dart';
import 'package:jobster/screen/principalPlazasScreen.dart';
import 'package:jobster/screen/verGuardadosScreen';
import 'screen/pre-login.dart';
import 'screen/publicarPlazaScreen.dart';
import 'screen/perfilScreen.dart';
import 'services/navigation_service.dart';
import 'services/Session.dart';

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
  bool tieneAccesoPublicar = false;

  final List<Widget> _pages = [
    const PrincipalPlazasScreen(),
    // const Center(child: Text('Inicio')),
    const PublicarPlazaScreen(),
    const VerGuardadosScreen(),
    const PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Verificar acceso al iniciar la pantalla
    _verificarAcceso();
  }

  Future<void> _verificarAcceso() async {
    if (Session.isLoggedIn && Session.usuario_id != null) {
      await Session.obtenerPantallasDisponibles(Session.usuario_id);
      setState(() {
        tieneAccesoPublicar = Session.tieneAccesoAPantalla('Publicar');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos los elementos disponibles para la barra de navegación
    final navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
      if (tieneAccesoPublicar)
        const BottomNavigationBarItem(
            icon: Icon(Icons.control_point, size: 35), label: 'Publicar'),
      
      const BottomNavigationBarItem(icon: Icon(Icons.save_alt_rounded), label: 'Guardados' ),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      
    ];

    // Aseguramos que el índice seleccionado sea válido
    if (_selectedIndex >= navItems.length) {
      _selectedIndex = navItems.length - 1;
    }

    // Calculamos qué página mostrar basado en los elementos disponibles
    int pageIndex = _selectedIndex;
    if (!tieneAccesoPublicar && _selectedIndex >= 1) {
      // Si no tiene acceso a publicar y el índice es 1 o más, usar índice 2
      pageIndex = _selectedIndex + 1;
    }

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
            Image.asset(
              'assets/Jobster_logo_largo.png',
              height: 45,
              width: 140,
            ),
          ],
        ),
        actions: [
          IconButton(
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
        // Usamos pageIndex para acceder a _pages
        child: pageIndex < _pages.length ? _pages[pageIndex] : _pages[0],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 107, 0),
        onTap: _onItemTapped,
        items: navItems,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
