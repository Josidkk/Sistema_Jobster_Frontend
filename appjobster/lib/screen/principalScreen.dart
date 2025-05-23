import 'package:flutter/material.dart';

class principalScreen extends StatelessWidget {
  const principalScreen({super.key});

  @override
  Widget build(BuildContext context) {

      return Scaffold(
            appBar:AppBar(title: const Text('Pantalla Principal'),
            ),
            body: const Center (
            child: Text('Hola Mundito'),
          ),

      );


  }
}