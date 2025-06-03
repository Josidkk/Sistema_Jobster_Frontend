import 'package:jobster/models/usuarioViewModel.dart';
import 'package:jobster/services/usuarioService.dart';
import 'package:flutter/material.dart';
import '../screen/principalScreen.dart';
import 'restablecerContrasenaScreen.dart';
import '../main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toasty_box/toasty_box.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:jobster/services/Session.dart';
import 'package:jobster/services/navigation_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UsuarioService _usuarioService = UsuarioService();

  bool _cargando = false;
  bool _obscureText = true;
  final bool _rememberMe = false;
  String _mensaje = '';

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _cargando = true;
        _mensaje = '';
      });

      try {
        final Usuario? usuario = await _usuarioService.login(
          _usuarioController.text.trim(),
          _contrasenaController.text.trim(),
        );
        if (usuario != null) {
          // setState(() {
          //   _mensaje = 'Bienvenido';
          // });

          await Flushbar(
            message: 'Bienvenido ${usuario.pers_Nombres ?? ''}',
            flushbarStyle: FlushbarStyle.FLOATING,
            icon: const Icon(Icons.check, color: Colors.white),
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.green,
            borderRadius: BorderRadius.circular(8),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            duration: const Duration(seconds: 1),
          ).show(context);

          try {
            Session.login(usuario.usua_Nombre);
            Session.id(usuario.usua_Id);
          
          } catch (e) {}

         NavigationService.navigateWithFade(
                          context,
                          const MainNavigationScreen(),
                        );
        } else {
          setState(() {
            _mensaje = 'Usuario o contraseña incorrectos';
            _cargando = false;
          });
        }
      } catch (e) {
        setState(() {
          _mensaje = 'ERROR AL INICIAR SESION $e';
          _cargando = false;
        });
      } finally {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B00); // Naranja principal
    const Color accentColor = Color(0xFFFF9A4D); // Naranja más claro

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/JobsterBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 0,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.0),
                    borderRadius: BorderRadius.circular(15),
                  ),

                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -30),
                          child: Image.asset(
                            'assets/logo_blanco.png',
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Iniciar Sesion',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),

                        const Text(
                          'Usuario',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        TextFormField(
                          controller: _usuarioController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Ejemplo: juan12',
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 158, 158, 158)
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: primaryColor,
                                width: 1,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su usuario';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        TextFormField(
                          controller: _contrasenaController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'contraseña',
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 158, 158, 158)
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: primaryColor,
                                width: 1,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _cargando ? null : _iniciarSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: primaryColor.withOpacity(
                              0.7,
                            ),
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: TextButton(
                            onPressed: () {
                           

                             NavigationService.navigateWithFade(
                                context,
                                const RestablecerContrasenaScreen(),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        if (_mensaje.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _mensaje,
                              style: TextStyle(
                                color: _mensaje.contains('Bienvenido')
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
