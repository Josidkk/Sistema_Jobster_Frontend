import 'package:flutter/material.dart';
import '../models/usuarioViewModel.dart';
import '../services/usuarioAprobadoService.dart';
import 'package:another_flushbar/flushbar.dart';

class ListarAprobadosScreen extends StatefulWidget {
  const ListarAprobadosScreen({super.key});

  @override
  State<ListarAprobadosScreen> createState() => _ListarAprobadosScreenState();
}

class _ListarAprobadosScreenState extends State<ListarAprobadosScreen> {
  final UsuarioAprobadoService _usuarioService = UsuarioAprobadoService();
  List<Usuario> _usuarios = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Método simplificado para obtener el estado de aprobación
  bool getApprovalStatus(Usuario usuario) {
    return usuario.usua_Aprobado ?? false;
  }

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    try {
      final usuarios = await _usuarioService.getUsuariosAprobados();

      setState(() {
        _usuarios = usuarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarMensaje('Error al cargar usuarios: $e', color: Colors.red);
    }
  }

  Future<void> _cambiarEstadoAprobacion(Usuario usuario) async {
    // Evitar múltiples solicitudes mientras se procesa una
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Determinamos el nuevo estado basado en el estado actual
      final bool estadoActual = getApprovalStatus(usuario);
      final bool nuevoEstado = !estadoActual;
      final String accion = nuevoEstado ? 'aprobado' : 'desaprobado';

      print('Estado actual: $estadoActual, Nuevo estado: $nuevoEstado');

      // Llamamos al servicio para actualizar
      final resultado = await _usuarioService.aprobarUsuario(
        usuario.usua_Id!,
        nuevoEstado,
      );

      if (resultado) {
        // Recargamos la lista para obtener el estado actualizado
        await _cargarUsuarios();

        // Mostrar mensaje de éxito
        _mostrarMensaje(
          'Usuario $accion correctamente',
          color: nuevoEstado ? Colors.green : Colors.orange,
        );
      } else {
        // Mostrar mensaje de error
        _mostrarMensaje(
          'No se pudo ${nuevoEstado ? 'aprobar' : 'desaprobar'} el usuario',
          color: Colors.red,
        );
      }
    } catch (e) {
      // Mostrar mensaje de error
      _mostrarMensaje('Error: ${e.toString()}', color: Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _mostrarMensaje(String mensaje, {Color? color}) {
    Flushbar(
      message: mensaje,
      duration: const Duration(seconds: 3),
      backgroundColor: color ?? Colors.green,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarUsuarios,
              child: ListView.builder(
                itemCount: _usuarios.length,
                itemBuilder: (context, index) {
                  final usuario = _usuarios[index];
                  final bool estaAprobado = getApprovalStatus(usuario);

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            usuario.usua_Imagen != "string" &&
                                usuario.usua_Imagen != null
                            ? NetworkImage(usuario.usua_Imagen!)
                            : null,
                        child:
                            usuario.usua_Imagen == "string" ||
                                usuario.usua_Imagen == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        '${usuario.pers_Nombres ?? ""} ${usuario.pers_Apellidos ?? ""}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Usuario: ${usuario.usua_Nombre}'),
                          Text('Correo: ${usuario.usua_Correo ?? ""}'),
                          Text('Rol: ${usuario.role_Descripcion ?? ""}'),
                          Text(
                            'Estado: ${estaAprobado ? "Aprobado" : "Pendiente"}',
                            style: TextStyle(
                              color: estaAprobado
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _cambiarEstadoAprobacion(usuario),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: estaAprobado
                              ? const Color.fromARGB(
                                  255,
                                  255,
                                  200,
                                  200,
                                ) // Rojo claro para desaprobar
                              : const Color.fromARGB(
                                  255,
                                  200,
                                  255,
                                  200,
                                ), // Verde claro para aprobar
                          foregroundColor: estaAprobado
                              ? Colors.red[800]
                              : Colors.green[800],
                        ),
                        child: Text(
                          estaAprobado ? 'Desaprobar' : 'Aprobar',
                          style: TextStyle(
                            color: estaAprobado
                                ? Colors.red[800]
                                : Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
