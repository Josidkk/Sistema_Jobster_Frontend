import 'package:flutter/material.dart';

/// Servicio que proporciona métodos para navegar entre pantallas con animaciones personalizadas
class NavigationService {
  /// Navega a una nueva pantalla con una animación de deslizamiento desde la derecha
  static Route createSlideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Desde la derecha
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Navega a una nueva pantalla con una animación de desvanecimiento
  static Route createFadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Navega a una nueva pantalla con una combinación de deslizamiento y desvanecimiento
  static Route createSlideFadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.fastOutSlowIn;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Método para navegar con la animación de deslizamiento
  static void navigateWithSlide(BuildContext context, Widget page) {
    Navigator.of(context).push(createSlideRoute(page));
  }

  /// Método para navegar con la animación de desvanecimiento
  static void navigateWithFade(BuildContext context, Widget page) {
    Navigator.of(context).push(createFadeRoute(page));
  }

  /// Método para navegar con la animación combinada
  static void navigateWithSlideFade(BuildContext context, Widget page) {
    Navigator.of(context).push(createSlideFadeRoute(page));
  }
}
