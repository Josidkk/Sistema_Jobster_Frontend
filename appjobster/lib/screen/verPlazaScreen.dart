// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:jobster/services/Session.dart';

import '../models/UsuarioViewModel.dart';
import '../services/usuarioService.dart';
import 'package:flutter/material.dart';

import '../screen/principalScreen.dart';
import '../services/plazaService.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VerPlazaScreen extends StatefulWidget {
  const VerPlazaScreen({super.key});

  @override
  State<VerPlazaScreen> createState() => _VerPlazaScreenState();
}

class _VerPlazaScreenState extends State<VerPlazaScreen> {
  final _plazaService = PlazaService();

  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _informacionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  int? _selectedCargoId;
  int? _selectedCategoriaId;
  int? _selectedTipoContratoId;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UsuarioService _usuarioService = UsuarioService();

  late final cargosList;
  late final municipiosList;
  late final categoriasList;
  late final tiposContratoList;
  late final plazasList;
  late final solicitudesList;
  late final guardadosList;
  late final List listadomunicipios;



  bool _cargando = false;
  final bool _obscureText = true;
  final bool _rememberMe = false;
  String _mensaje = '';


  void cargarPlazas() async {
    plazasList = await _plazaService.listarPlazas();
  }


    Future<void> llenarMunicipios() async {


    try {
      final listadomuni = await _plazaService.getMunicipios();

      if (listadomuni != null) {

        listadomunicipios = listadomuni;


      } else {

        debugPrint('listado vacio muni');
      }
    } catch (e) {

      debugPrint('Error al cargar municipioslist: $e');
    }



  }

  void _enviarSolicitud(String? plazaid, String? usuaid) async {
  // if (_formKey.currentState!.validate()) {
  //   setState(() {
  //     _cargando = true;
  //     _mensaje = '';
  //   });

    try {

      final respuesta = await _plazaService.crearSolicitud(plazaid, usuaid);


        if (respuesta.toString().toLowerCase().contains('creada')) {
          setState(() {
            _mensaje = 'Solicitud enviada';
          });
        } else {
          setState(() {
            _mensaje = 'Error al enviar solicitud: $respuesta';
            _cargando = false;
          });
        }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VerPlazaScreen()),
          );
        

    } catch (e) {
      setState(() {
        _mensaje = 'ERROR AL Enviar Solicitud $e';
        _cargando = false;
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  void _cancelarSolicitud(String? soliId) async {
  // if (_formKey.currentState!.validate()) {
  //   setState(() {
  //     _cargando = true;
  //     _mensaje = '';
  //   });

    try {

      final respuesta = await _plazaService.eliminarSolicitud(soliId);


        if (respuesta.toString().toLowerCase().contains('eliminada')) {
          setState(() {
            _mensaje = 'Solicitud Cancelada';
          });
        } else {
          setState(() {
            _mensaje = 'Error al cancelar solicitud: $respuesta';
            _cargando = false;
          });
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerPlazaScreen()),
        );
        

    } catch (e) {
      setState(() {
        _mensaje = 'ERROR AL Cancelar Solicitud $e';
        _cargando = false;
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }


  void _guardarPlaza(String? plazaid, String? usuaid) async {

    try {

      final respuesta = await _plazaService.crearGuardado(plazaid, usuaid);


        if (respuesta.toString().toLowerCase().contains('creada')) {
          setState(() {
            _mensaje = 'Plaza guardada';
          });
        } else {
          setState(() {
            _mensaje = 'Error al guardar plaza: $respuesta';
            _cargando = false;
          });
        }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VerPlazaScreen()),
          );
        

    } catch (e) {
      setState(() {
        _mensaje = 'ERROR AL guardar plaza $e';
        _cargando = false;
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  void _descartarGuardado(String? guardadoId) async {

    try {

      final respuesta = await _plazaService.eliminarGuardado(guardadoId);


        if (respuesta.toString().toLowerCase().contains('eliminada')) {
          setState(() {
            _mensaje = 'Plaza descartada de Guardados';
          });
        } else {
          setState(() {
            _mensaje = 'Error al descartar plaza: $respuesta';
            _cargando = false;
          });
        }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VerPlazaScreen()),
          );
        

    } catch (e) {
      setState(() {
        _mensaje = 'ERROR AL descartar plaza $e';
        _cargando = false;
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    cargosList = _plazaService.getCargos();
    categoriasList = _plazaService.getCategorias();
    municipiosList = _plazaService.getMunicipios();
    tiposContratoList = _plazaService.getTiposContrato();
    plazasList = _plazaService.buscarPlaza(Session.plaza_Id!);
    solicitudesList = _plazaService.getSolicitudes();
    guardadosList = _plazaService.getGuardados();
    llenarMunicipios();


  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }



  // Helper widget for details
  Widget _detalleItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFEE4D00), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
  const Color primaryColor = Color(0xFFFF6B00);
  const Color accentColor = Color(0xFFFF9A4D);

  return Scaffold(
    appBar: AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: const Text(
        'Detalle de Plaza',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: Container(
      decoration: const BoxDecoration(
        color: Colors.white10,
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Container(
                padding: const EdgeInsets.only(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FutureBuilder<List<dynamic>>(
                        future: plazasList,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            // return LinearProgressIndicator();
                            return SizedBox(
                              height: 300,
                              
                              
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No hay plazas');
                          } else {
                            final plazas = snapshot.data!;
                            final plaza = plazas.first;

                            final String plazaImagen = plaza['plaz_Imagen'] ?? '';
                            final String plazaDescripcion = plaza['plaz_Descripcion'] ?? 'Título de la Plaza';
                            final String plazaInformacion = plaza['plaz_Informacion'] ?? 'Información detallada de la plaza...';
                            final String plazaRequisitos = plaza['plaz_Requisitos'] ?? 'Requisitos de la plaza...';
                            final String plazaDireccion = plaza['plaz_Direccion'] ?? 'Dirección';
                            final String plazaMunicipio = plaza['muni_Descripcion'] ?? 'Municipio';
                            final String plazaTipoContrato = plaza['tico_Descripcion'] ?? 'Tipo de Contrato';
                            final String plazaCargo = plaza['carg_Descripcion'] ?? 'Cargo';
                            final String plazaCategoria = plaza['cate_Descripcion'] ?? 'Categoría';
                            final String contactoNombre = plaza['contacto_Nombre'] ?? 'Nombre de Contacto';
                            final String contactoCorreo = plaza['contacto_Correo'] ?? 'Correo de Contacto';
                            final String contactoTelefono = plaza['contacto_Telefono'] ?? 'Teléfono de Contacto';

                            final String muniCodigo = plaza['muni_Codigo'] ?? '0000';

                            // final muniDescripcion = listadomunicipios.firstWhere((element) => element['muni_Codigo'] == muniCodigo);





                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Imagen principal
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      plazaImagen,
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 220,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Título y botones
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          plazaDescripcion,
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFEE4D00),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [


                                      FutureBuilder<List<dynamic>>(
                                            future: solicitudesList,
                                            builder: (context, solicitudesSnapshot) {
                                              if (solicitudesSnapshot.connectionState == ConnectionState.waiting) {
                                                return Expanded(
                                                  child: LinearProgressIndicator()
                                                  );
                                              } else if (solicitudesSnapshot.hasError) {
                                                return 
                                                Expanded(
                                                    child: 
                                                    // ElevatedButton.icon(
                                                    //   onPressed: () {

                                                    //     // TODO: Solicitar plaza
                                                    //   },
                                                    //   icon: const Icon(Icons.send),
                                                    //   label: const Text('NO INFO'),
                                                    //   style: ElevatedButton.styleFrom(
                                                    //     backgroundColor: primaryColor,
                                                    //     foregroundColor: Colors.white,
                                                    //     shape: RoundedRectangleBorder(
                                                    //       borderRadius: BorderRadius.circular(6),
                                                    //     ),
                                                    //     padding: const EdgeInsets.symmetric(vertical: 10),
                                                    //   ),
                                                    // ),
                                                    LinearProgressIndicator()

                                                  );
                                              } 
                                              // else if (!solicitudesSnapshot.hasData || solicitudesSnapshot.data!.isEmpty) {                                                
                                              // } 
                                              else {

                                                final solicitudes = solicitudesSnapshot.data!;

                                                final solicitudesfinal = solicitudes.where(
                                                  (m) => m['plaz_Id'].toString() == Session.plaza_Id &&
                                                  m['usua_Id'] == Session.usuario_id

                                                );

                                                if (solicitudesfinal.isEmpty) {

                                                  return (Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {
                                                        _enviarSolicitud(Session.plaza_Id, Session.usuario_id.toString());
                                                        
                                                        
                                                        // TODO: Solicitar plaza
                                                      },
                                                      icon: const Icon(Icons.send),
                                                      label: const Text('Solicitar'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: primaryColor,
                                                        foregroundColor: Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                      ),
                                                    ),
                                                  )
                                                  );

                                                }
                                                else{
                                                  return (
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: () {
                                                          // _enviarSolicitud(Session.plaza_Id, Session.usuario_id.toString());
                                                          _cancelarSolicitud(solicitudesfinal.first['soli_Id'].toString());
                                                          
                                                        
                                                        

                                                          // TODO: Solicitar plaza
                                                        },
                                                        icon: const Icon(Icons.cancel_sharp),
                                                        label: const Text('Cancelar Solicitud'),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: primaryColor,
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                                        ),
                                                      ),
                                                    )
                                                  );
                                                }


                                              }
                                            },

                                          ),


                                      // Expanded(
                                      //   child: ElevatedButton.icon(
                                      //     onPressed: () {
                                      //       _enviarSolicitud(Session.plaza_Id, Session.usuario_id.toString());
                                      //       // TODO: Solicitar plaza
                                      //     },
                                      //     icon: const Icon(Icons.send),
                                      //     label: const Text('Solicitar'),
                                      //     style: ElevatedButton.styleFrom(
                                      //       backgroundColor: primaryColor,
                                      //       foregroundColor: Colors.white,
                                      //       shape: RoundedRectangleBorder(
                                      //         borderRadius: BorderRadius.circular(6),
                                      //       ),
                                      //       padding: const EdgeInsets.symmetric(vertical: 10),
                                      //     ),
                                      //   ),
                                      // ),


                                      const SizedBox(width: 12),
                                      


                                          FutureBuilder<List<dynamic>>(
                                            future: guardadosList,
                                            builder: (context, guardadosSnapshot) {
                                              if (guardadosSnapshot.connectionState == ConnectionState.waiting) {
                                                return Expanded(
                                                  child: LinearProgressIndicator()
                                                  );
                                              } else if (guardadosSnapshot.hasError) {
                                                return 
                                                Expanded(
                                                    child: 
                                                    // ElevatedButton.icon(
                                                    //   onPressed: () {

                                                    //   },
                                                    //   icon: const Icon(Icons.send),
                                                    //   label: const Text('NO INFO'),
                                                    //   style: ElevatedButton.styleFrom(
                                                    //     backgroundColor: primaryColor,
                                                    //     foregroundColor: Colors.white,
                                                    //     shape: RoundedRectangleBorder(
                                                    //       borderRadius: BorderRadius.circular(6),
                                                    //     ),
                                                    //     padding: const EdgeInsets.symmetric(vertical: 10),
                                                    //   ),
                                                    // ),
                                                    LinearProgressIndicator()

                                                  );
                                              } 
                                              // else if (!solicitudesSnapshot.hasData || solicitudesSnapshot.data!.isEmpty) {                                                
                                              // } 
                                              else {

                                                final guardados = guardadosSnapshot.data!;

                                                final guardadosfinal = guardados.where(
                                                  (m) => m['plaz_Id'].toString() == Session.plaza_Id &&
                                                  m['usua_Id'] == Session.usuario_id

                                                );

                                                if (guardadosfinal.isEmpty) {

                                                  return (
                                                    Expanded(
                                                      child: OutlinedButton.icon(
                                                        onPressed: () {
                                                          _guardarPlaza(Session.plaza_Id, Session.usuario_id.toString());
                                                          
                                                        },
                                                        icon: const Icon(Icons.bookmark_border),
                                                        label: const Text('Guardar'),
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor: primaryColor,
                                                          side: const BorderSide(color: primaryColor),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                                        ),
                                                      ),
                                                    )
                                                  );

                                                }
                                                else{
                                                  return (
                                                    Expanded(
                                                      child: OutlinedButton.icon(
                                                        onPressed: () {
                                                          _descartarGuardado(guardadosfinal.first['guar_Id'].toString());
                                                          
                                                        },
                                                        icon: const Icon(Icons.bookmark_added_sharp),
                                                        label: const Text('Guardado'),
                                                        style: OutlinedButton.styleFrom(
                                                          backgroundColor: primaryColor,
                                                          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                                                          side: const BorderSide(color: primaryColor),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                                        ),

                                                      ),
                                                    )
                                                  );
                                                }


                                              }
                                            },

                                          ),

                                      // Expanded(
                                      //   child: OutlinedButton.icon(
                                      //     onPressed: () {


                                      //       // TODO: Guardar plaza
                                      //     },
                                      //     icon: const Icon(Icons.bookmark_border),
                                      //     label: const Text('Guardar'),
                                      //     style: OutlinedButton.styleFrom(
                                      //       foregroundColor: primaryColor,
                                      //       side: const BorderSide(color: primaryColor),
                                      //       shape: RoundedRectangleBorder(
                                      //         borderRadius: BorderRadius.circular(6),
                                      //       ),
                                      //       padding: const EdgeInsets.symmetric(vertical: 10),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Información de la plaza
                                  const Text(
                                    'Información',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    plazaInformacion,
                                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 24),

                                  // Requisitos
                                  const Text(
                                    'Requisitos',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    plazaRequisitos,
                                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 24),

                                  // Detalles de la plaza
                                  const Text(
                                    'Detalles de la Plaza',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Card(
                                    color: const Color(0xFFFFF3E0),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _detalleItem(Icons.location_on, 'Dirección', plazaDireccion),

                                          FutureBuilder<List<dynamic>>(
                                            future: municipiosList,
                                            builder: (context, muniSnapshot) {
                                              if (muniSnapshot.connectionState == ConnectionState.waiting) {
                                                return const SizedBox(
                                                  height: 20,
                                                  child: LinearProgressIndicator(),
                                                );
                                              } else if (muniSnapshot.hasError) {
                                                return _detalleItem(Icons.location_city, 'Municipio', 'Error');
                                              } else if (!muniSnapshot.hasData || muniSnapshot.data!.isEmpty) {
                                                return _detalleItem(Icons.location_city, 'Municipio', 'No encontrado');
                                              } else {
                                                final municipios = muniSnapshot.data!;
                                                final String? municipioCodigo = plaza['muni_Codigo'];
                                                final municipio = municipios.firstWhere(
                                                  (m) => m['muni_Codigo'] == municipioCodigo,
                                                  orElse: () => null,
                                                );
                                                final String municipioDescripcion = municipio != null
                                                    ? municipio['muni_Descripcion']
                                                    : 'Municipio no encontrado';
                                                return _detalleItem(Icons.location_city, 'Municipio', municipioDescripcion);
                                              }
                                            },
                                          ),


                                          FutureBuilder<List<dynamic>>(
                                            future: tiposContratoList,
                                            builder: (context, ticoSnapshot) {
                                              if (ticoSnapshot.connectionState == ConnectionState.waiting) {
                                                return const SizedBox(
                                                  height: 20,
                                                  child: LinearProgressIndicator(),
                                                );
                                              } else if (ticoSnapshot.hasError) {
                                                return _detalleItem(Icons.location_city, 'Municipio', 'Error');
                                              } else if (!ticoSnapshot.hasData || ticoSnapshot.data!.isEmpty) {
                                                return _detalleItem(Icons.location_city, 'Municipio', 'No encontrado');
                                              } else {
                                                final tipos = ticoSnapshot.data!;
                                                final int? ticoid = plaza['tiCo_Id'];
                                                final tipocontrato = tipos.firstWhere(
                                                  (m) => m['tiCo_Id'] == ticoid,
                                                  orElse: () => null,
                                                );
                                                final String ticoDescripcion = tipocontrato != null
                                                    ? tipocontrato['tiCo_Descripcion']
                                                    : 'Municipio no encontrado';
                                                return _detalleItem(Icons.assignment, 'Tipo de Contrato', ticoDescripcion);
                                              }
                                            },
                                          ),

                                          // _detalleItem(Icons.assignment, 'Tipo de Contrato', plazaTipoContrato),


                                          FutureBuilder<List<dynamic>>(
                                            future: cargosList,
                                            builder: (context, ticoSnapshot) {
                                              if (ticoSnapshot.connectionState == ConnectionState.waiting) {
                                                return const SizedBox(
                                                  height: 20,
                                                  child: LinearProgressIndicator(),
                                                );
                                              } else if (ticoSnapshot.hasError) {
                                                return _detalleItem(Icons.location_city, 'Cargo', 'Error');
                                              } else if (!ticoSnapshot.hasData || ticoSnapshot.data!.isEmpty) {
                                                return _detalleItem(Icons.location_city, 'Cargo', 'No encontrado');
                                              } else {
                                                final tipos = ticoSnapshot.data!;
                                                final int? ticoid = plaza['carg_Id'];
                                                final tipocontrato = tipos.firstWhere(
                                                  (m) => m['carg_Id'] == ticoid,
                                                  orElse: () => null,
                                                );
                                                final String ticoDescripcion = tipocontrato != null
                                                    ? tipocontrato['carg_Descripcion']
                                                    : 'Cargo no encontrado';
                                                return _detalleItem(Icons.work, 'Cargo', ticoDescripcion);
                                              }
                                            },
                                          ),

                                          // _detalleItem(Icons.work, 'Cargo', plazaCargo),

                                          FutureBuilder<List<dynamic>>(
                                            future: categoriasList,
                                            builder: (context, ticoSnapshot) {
                                              if (ticoSnapshot.connectionState == ConnectionState.waiting) {
                                                return const SizedBox(
                                                  height: 20,
                                                  child: LinearProgressIndicator(),
                                                );
                                              } else if (ticoSnapshot.hasError) {
                                                return _detalleItem(Icons.location_city, 'Categoria', 'Error');
                                              } else if (!ticoSnapshot.hasData || ticoSnapshot.data!.isEmpty) {
                                                return _detalleItem(Icons.location_city, 'Categoria', 'No encontrado');
                                              } else {
                                                final tipos = ticoSnapshot.data!;
                                                final int? ticoid = plaza['cate_Id'];
                                                final tipocontrato = tipos.firstWhere(
                                                  (m) => m['cate_Id'] == ticoid,
                                                  orElse: () => null,
                                                );
                                                final String ticoDescripcion = tipocontrato != null
                                                    ? tipocontrato['cate_Descripcion']
                                                    : 'Categoria no encontrada';
                                                return _detalleItem(Icons.category, 'Categoría', ticoDescripcion);
                                              }
                                            },
                                          ),

                                          // _detalleItem(Icons.category, 'Categoría', plazaCategoria),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Información de contacto
                                  const Text(
                                    'Información de Contacto',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Card(
                                    color: const Color(0xFFFFF3E0),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _detalleItem(Icons.person, 'Nombre', contactoNombre),
                                          _detalleItem(Icons.email, 'Correo', contactoCorreo),
                                          _detalleItem(Icons.phone, 'Teléfono', contactoTelefono),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      if (_mensaje.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _mensaje,
                            style: TextStyle(
                              color: _mensaje.contains('enviada') || _mensaje.toLowerCase().contains('publicada')
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