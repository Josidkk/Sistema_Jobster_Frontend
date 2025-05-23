import 'package:appjobster/models/usuarioViewModel.dart';
import 'package:appjobster/services/usuarioService.dart';
import 'package:flutter/material.dart';
import '../screen/principalScreen.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  
  final GlobalKey<FormState> _formKey = GlobalKey <FormState>();
  final UsuarioService _usuarioService = UsuarioService();

  bool _cargando = false;
  String _mensaje = '';
@override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _iniciarSesion() async
  {
    if(!_formKey.currentState!.validate())
    {
      _cargando = true;
      setState(() {
        _mensaje = '';
      });

      try
        {
          final Usuario? usuario = await _usuarioService.login(
            _usuarioController.text.trim(),
            _contrasenaController.text.trim(),
          );
          if(usuario != null)
          {
            setState(() {
              _mensaje = 'Bienvenido';
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const principalScreen(),
              ),
            );
          }
          else
          {
            setState(() {
              _mensaje = 'Usuario o contraseña incorrectos';
            });
          }

        }
      catch(e)
        {
          setState(() {
            _mensaje = 'ERROR AL INICIAR SESION $e';
          });
        }

      finally{ _cargando = false;}
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesion'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              TextFormField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su usuario';
                  }
                  return null;
                },

              ),
 const SizedBox(height: 16),
              // Contraseña
              TextFormField(
                controller: _contrasenaController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  return null;
                },
              ),
 const SizedBox(height: 16),

 ElevatedButton(
  onPressed: _cargando ? null : _iniciarSesion,
  child: _cargando
      ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 119, 255, 142)),
          ),
        )
      : const Text('Iniciar Sesión'),
),
  const SizedBox(height: 16),
  Text(_mensaje,
   style: TextStyle(
  color: _mensaje.contains('exitoso') ? Colors.greenAccent : Colors.redAccent,
  fontWeight: FontWeight.bold,
),
    )

              ]
              
              , 
            ),
          ),
        ),
      ),
    );
  }
}