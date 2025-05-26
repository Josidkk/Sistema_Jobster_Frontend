import 'package:flutter/material.dart';
import 'loginScreen.dart';

class CodigoScreen extends StatefulWidget {
  final String codigoVerificacion;
  final String correo;

  const CodigoScreen({
    Key? key,
    required this.codigoVerificacion,
    required this.correo,
  }) : super(key: key);

  @override
  State<CodigoScreen> createState() => _CodigoScreenState();
}

class _CodigoScreenState extends State<CodigoScreen> {
  final TextEditingController _codigoController = TextEditingController();
  String _mensaje = '';
  bool _cargando = false;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  void _verificarCodigo() {
    final codigoIngresado = _codigoController.text.trim();
    
    if (codigoIngresado == widget.codigoVerificacion) {
      setState(() {
        _mensaje = 'Código correcto';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NuevaContrasenaScreen(correo: widget.correo),
        ),
      );
    } else {
      setState(() {
        _mensaje = 'Código incorrecto. Intente nuevamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B00);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Código'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/JobsterBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ingrese el código de verificación enviado a su correo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _codigoController,
                  decoration: InputDecoration(
                    labelText: 'Código de verificación',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                const SizedBox(height: 20),
                if (_mensaje.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _mensaje,
                      style: TextStyle(
                        color: _mensaje.contains('incorrecto') ? Colors.red : Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _cargando ? null : _verificarCodigo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verificar Código'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NuevaContrasenaScreen extends StatefulWidget {
  final String correo;

  const NuevaContrasenaScreen({
    Key? key,
    required this.correo,
  }) : super(key: key);

  @override
  State<NuevaContrasenaScreen> createState() => _NuevaContrasenaScreenState();
}

class _NuevaContrasenaScreenState extends State<NuevaContrasenaScreen> {
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController = TextEditingController();
  String _mensaje = '';
  bool _cargando = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  void _cambiarContrasena() async {
    if (_contrasenaController.text != _confirmarContrasenaController.text) {
      setState(() {
        _mensaje = 'Las contraseñas no coinciden';
      });
      return;
    }

    setState(() {
      _cargando = true;
      _mensaje = '';
    });

    // TODO: Implementar el cambio de contraseña usando el servicio
    // Ejemplo:
    // try {
    //   await _usuarioService.cambiarContrasena(widget.correo, _contrasenaController.text);
    //   Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    // } catch (e) {
    //   setState(() {
    //     _mensaje = 'Error al cambiar la contraseña: $e';
    //     _cargando = false;
    //   });
    // }

    // Por ahora solo navegamos al login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B00);

    return Scaffold(
      
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/JobsterBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _contrasenaController,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureText,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _confirmarContrasenaController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureText,
                ),
                const SizedBox(height: 20),
                if (_mensaje.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _mensaje,
                      style: TextStyle(
                        color: _mensaje.contains('no coinciden') ? Colors.red : Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _cargando ? null : _cambiarContrasena,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Cambiar Contraseña'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
