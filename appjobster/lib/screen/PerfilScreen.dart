import 'package:flutter/material.dart';
import 'package:jobster/services/Session.dart';
import '../services/UsuarioService.dart';
import '../services/PersonaService.dart';
import '../screen/pre-login.dart';
import '../models/usuarioViewModel.dart';
import '../models/PersonasViewModel.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Usuario? _usuario;
  Persona? _persona;
  bool _isLoading = true;
  bool _isEditingNombre = false;
  bool _isEditingCorreo = false;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final usuario = await UsuarioService().buscarUsuario(Session.usua_Id!);
      if (usuario != null && usuario.pers_Id != null) {
        final persona = await PersonaService().buscarPersona(usuario.pers_Id!);

        setState(() {
          _usuario = usuario;
          _persona = persona;
          _nombreController.text = _usuario?.usua_Nombre ?? '';
          _correoController.text = _usuario?.usua_Correo ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint('Usuario no encontrado o sin pers_Id');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al cargar datos: $e');
    }
  }

  Future<void> _guardarNombre() async {
    if (_usuario == null) return;
    setState(() => _isLoading = true);
    try {
      final usuarioActualizado = Usuario(
        usua_Id: _usuario!.usua_Id,
        usua_Nombre: _nombreController.text,
        usua_Contrasena: _usuario!.usua_Contrasena,
        usua_Correo: _usuario!.usua_Correo,
        usua_EsAdmin: _usuario!.usua_EsAdmin,
        usua_Publicador: _usuario!.usua_Publicador,
        usua_Imagen: _usuario!.usua_Imagen,
        pers_Id: _usuario!.pers_Id,
        role_Id: _usuario!.role_Id,
        pers_Nombres: _usuario!.pers_Nombres,
        pers_Apellidos: _usuario!.pers_Apellidos,
        role_Descripcion: _usuario!.role_Descripcion,
        usua_Creacion: _usuario!.usua_Creacion,
        usua_FechaCreacion: _usuario!.usua_FechaCreacion,
        usua_Modificacion: _usuario!.usua_Modificacion,
        usua_FechaModificacion: _usuario!.usua_FechaModificacion,
        usua_Estado: _usuario!.usua_Estado,
      );

      final success = await UsuarioService().editarUsuario(usuarioActualizado);

      if (success) {
        setState(() {
          _usuario = usuarioActualizado;
          _isEditingNombre = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre de usuario actualizado correctamente')),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el nombre de usuario')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al guardar nombre: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  Future<void> _guardarCorreo() async {
    if (_usuario == null) return;
    setState(() => _isLoading = true);
    try {
      final usuarioActualizado = Usuario(
        usua_Id: _usuario!.usua_Id,
        usua_Nombre: _usuario!.usua_Nombre,
        usua_Contrasena: _usuario!.usua_Contrasena,
        usua_Correo: _correoController.text,
        usua_EsAdmin: _usuario!.usua_EsAdmin,
        usua_Publicador: _usuario!.usua_Publicador,
        usua_Imagen: _usuario!.usua_Imagen,
        pers_Id: _usuario!.pers_Id,
        role_Id: _usuario!.role_Id,
        pers_Nombres: _usuario!.pers_Nombres,
        pers_Apellidos: _usuario!.pers_Apellidos,
        role_Descripcion: _usuario!.role_Descripcion,
        usua_Creacion: _usuario!.usua_Creacion,
        usua_FechaCreacion: _usuario!.usua_FechaCreacion,
        usua_Modificacion: _usuario!.usua_Modificacion,
        usua_FechaModificacion: _usuario!.usua_FechaModificacion,
        usua_Estado: _usuario!.usua_Estado,
      );

      final success = await UsuarioService().editarUsuario(usuarioActualizado);

      if (success) {
        setState(() {
          _usuario = usuarioActualizado;
          _isEditingCorreo = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo actualizado correctamente')),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el correo')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error al guardar correo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  void _cerrarSesion() {
  Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => prelogin()),
              );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B00), Color(0xFFEE4D00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage('assets/Jobster_logo_original.png'),
                                backgroundColor: Colors.white,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt, color: Colors.orange, size: 20),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Cambiar imagen de perfil')),
                                      );
                                    },
                                    tooltip: 'Cambiar imagen',
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_persona?.pers_Nombres ?? ''} ${_persona?.pers_Apellidos ?? ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _usuario?.role_Descripcion ?? 'Desconocido',
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        _isEditingNombre
                            ? SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: _nombreController,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Nombre de usuario',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              )
                            : Text(
                                _usuario?.usua_Nombre ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                        IconButton(
                          icon: Icon(_isEditingNombre ? Icons.check : Icons.edit),
                          onPressed: () {
                            if (_isEditingNombre) {
                              _guardarNombre();
                            } else {
                              setState(() => _isEditingNombre = true);
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        _isEditingCorreo
                            ? SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: _correoController,
                                  autofocus: true,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    hintText: 'Correo electrónico',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              )
                            : Text(
                                _usuario?.usua_Correo ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                        IconButton(
                          icon: Icon(_isEditingCorreo ? Icons.check : Icons.edit),
                          onPressed: () {
                            if (_isEditingCorreo) {
                              _guardarCorreo();
                            } else {
                              setState(() => _isEditingCorreo = true);
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'La plataforma que conecta talento con oportunidades',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _cerrarSesion,
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }
}
