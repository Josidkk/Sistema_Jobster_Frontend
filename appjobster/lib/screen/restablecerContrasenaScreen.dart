import 'package:jobster/models/usuarioViewModel.dart';
import 'package:jobster/services/usuarioService.dart';
import 'package:flutter/material.dart';
import '../screen/codigoScreen.dart';

class RestablecerContrasenaScreen extends StatefulWidget {
  const RestablecerContrasenaScreen({super.key});

  @override
  State<RestablecerContrasenaScreen> createState() =>
      _RestablecerContrasenaScreenState();
}

class _RestablecerContrasenaScreenState
    extends State<RestablecerContrasenaScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UsuarioService _usuarioService = UsuarioService();

  bool _cargando = false;
  bool _obscureText = true;
  bool _rememberMe = false;
  String? _codigoVerificacion;
  String _mensaje = '';

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _restablecerContrasena() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _cargando = true;
        _mensaje = '';
      });

      try {
        final Usuario? usuario = await _usuarioService.buscarUsuario(
          _usuarioController.text.trim(),
        );
        if (usuario != null) {
          setState(() {
            _mensaje = 'Bienvenido';
          });

          if (usuario.usua_Correo?.isEmpty ?? true) {
            setState(() {
              _mensaje = 'no se encontro el correo';
              _cargando = false;
            });
            return;
          }

          try {
            String codigoVerificacion = await _usuarioService.enviarCorreo(
              usuario.usua_Correo!,
            );
            setState(() {
              _mensaje = 'Se ha enviado el código al correo';
              _cargando = false;
            });

            // El código ya no es null porque viene directo de la API
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CodigoScreen(
                  codigoVerificacion: codigoVerificacion,
                  correo: usuario.usua_Correo!,
                ),
              ),
            );
          } catch (e) {
            setState(() {
              _mensaje = 'Error al enviar el correo: $e';
              _cargando = false;
            });
          }

          // aqui quiero que envie el codigo
        } else {
          setState(() {
            _mensaje = 'Usuario no encontrado';
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
                          'Restablecer Contraseña',
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
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            hintText: 'usuario',
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

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _cargando ? null : _restablecerContrasena,
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
                                  'Ingresa el usuario',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

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
