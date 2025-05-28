import 'package:flutter/material.dart';
import 'package:jobster/screen/registroUsuarioScreen.dart';
import 'package:jobster/services/navigation_service.dart';
import 'loginScreen.dart';

class prelogin extends StatelessWidget {
  const prelogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/JobsterBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo de Jobster
                    Image.asset(
                      'assets/Jobster_logo_original.png',
                      height: 100,
                    ),
                    const SizedBox(height: 15),

                    // Texto de bienvenida
                    const Text(
                      '¡Bienvenido a Jobster!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B00),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'La plataforma que conecta talento con oportunidades',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Botón de Iniciar Sesión
                    ElevatedButton(
                      onPressed: () {
                        // Usamos el servicio de navegación
                        NavigationService.navigateWithSlide(
                          context,
                          const LoginScreen(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFF6B00,
                        ), // Naranja de Jobster
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ya estuviste por aqui?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón de Registrarse
                    OutlinedButton(
                      onPressed: () {
                        // Usamos el servicio de navegación

  NavigationService.navigateWithSlide(
              context,
              const RegistroUsuarioScreen(),
            );

                       
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6B00),
                        side: const BorderSide(
                          color: Color(0xFFFF6B00),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
