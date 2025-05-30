  import 'package:flutter/material.dart';
  
  import '../screen/publicarPlazaScreen.dart';

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
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PublicarPlazaScreen()),

                );
              },
              child: const Icon(Icons.arrow_forward),
            ),

      );


  }
}