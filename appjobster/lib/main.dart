import 'package:flutter/material.dart';
import 'package:jobster/screen/principalPlazasScreen.dart';

import 'package:jobster/screen/verGuardadosScreen.dart';
import 'package:jobster/screen/verPlazasSolicitadasScreen.dart';
import 'screen/pre-login.dart';
import 'screen/publicarPlazaScreen.dart';
import 'screen/perfilScreen.dart';
import 'screen/listarAprobadosScreen.dart';
import 'screen/dashboardScreen.dart';
import 'services/navigation_service.dart';
import 'services/Session.dart';


void main() {
  runApp(const MyApp());
}

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

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
      navigatorObservers: [routeObserver],
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

  @override
  void initState() {
    super.initState();
    _verificarAcceso();
  }

  Future<void> _verificarAcceso() async {
    if (Session.isLoggedIn && Session.usuario_id != null) {
      await Session.obtenerPantallasDisponibles(Session.usuario_id);
      setState(() {});
    }
  }

  // Genera las pestañas disponibles según los permisos
  List<_TabConfig> get _availableTabs {
    List<_TabConfig> tabs = [
      _TabConfig(
        icon: Icons.home,
        label: 'Inicio',
        page: const PrincipalPlazasScreen(),
      ),
    ];

    if (Session.tieneAccesoAPantalla('Publicar')) {
      tabs.add(
        _TabConfig(
          icon: Icons.control_point,
          label: 'Publicar',
          page: const PublicarPlazaScreen(),
        ),
      );
    }

    if (Session.tieneAccesoAPantalla('Aprobaciones')) {
      tabs.add(
        _TabConfig(
          icon: Icons.check_circle,
          label: 'Aprobaciones',
          page: const ListarAprobadosScreen(),
        ),
      );
    }
    
    // Añadir la pestaña de Dashboard
    tabs.add(
      _TabConfig(
        icon: Icons.dashboard,
        label: 'Dashboard',
        page: const DashboardScreen(),
      ),
    );

    tabs.add(
      _TabConfig(
        icon: Icons.person,
        label: 'Perfil',
        page: const PerfilScreen(),
      ),
    );

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _availableTabs;

    // Asegura que el índice seleccionado sea válido
    if (_selectedIndex >= tabs.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              NavigationService.navigateWithFade(context, const prelogin());
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: tabs[_selectedIndex].page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 107, 0),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(
                  tab.icon,
                  size: tab.icon == Icons.control_point ? 35 : 24,
                ),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

// Clase helper para configurar cada pestaña
class _TabConfig {
  final IconData icon;
  final String label;
  final Widget page;

  _TabConfig({required this.icon, required this.label, required this.page});
}
