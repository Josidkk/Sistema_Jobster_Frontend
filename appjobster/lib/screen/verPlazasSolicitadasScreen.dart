// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

// import 'package:appjobster/models/usuarioViewModel.dart';
// import 'package:appjobster/services/usuarioService.dart';
import 'package:jobster/screen/verPlazaScreen.dart';
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

import '../main.dart';

class VerPlazasSolicitadasScreen extends StatefulWidget {
  const VerPlazasSolicitadasScreen({super.key});

  @override
  State<VerPlazasSolicitadasScreen> createState() => _VerPlazasSolicitadasScreenState();
}

class _VerPlazasSolicitadasScreenState extends State<VerPlazasSolicitadasScreen> {
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
  
  late final solicitudeslist;

  File? _selectedImage;

  bool _cargando = false;
  final bool _obscureText = true;
  final bool _rememberMe = false;
  String _mensaje = '';

  void cargarPlazas() async {
    // final plazaslis = await _plazaService.listarPlazas();
    plazasList = await _plazaService.listarPlazas();
  }

  @override
  void initState() {
    super.initState();
    cargosList = _plazaService.getCargos();
    categoriasList = _plazaService.getCategorias();
    municipiosList = _plazaService.getMunicipios();
    tiposContratoList = _plazaService.getTiposContrato();
    plazasList = _plazaService.listarPlazas();
    
    solicitudeslist = _plazaService.getSolicitudes();
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    ); // or ImageSource.camera

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B00); // Naranja principal
    const Color accentColor = Color(0xFFFF9A4D); // Naranja más claro

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Publicar Plaza',
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor: const Color(0xFFFF6B00), // Same as your primaryColor
      //   elevation: 0,
      //   iconTheme: const IconThemeData(color: Colors.white),
      // ),
      body: Container(
        decoration: const BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage('assets/JobsterBackground.png'),
          //   fit: BoxFit.cover,
          // ),
          color: Colors.white10
          // color: Color.fromARGB(255, 255, 134, 42),
          // color: Color.fromARGB(255, 225, 129, 19)
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
                  // constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        const Center(
                          child: Text(
                            'Tus Plazas Solicitadas',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEE4D00),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),



                        FutureBuilder<List<dynamic>>(
                          future: plazasList,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return 
                                Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        SizedBox(height: 40),
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE4D00)),
                                          strokeWidth: 4,
                                        ),
                                        SizedBox(height: 18),
                                        Text(
                                          'Cargando plazas Solicitadas...',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFFEE4D00),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(height: 40),
                                      ],
                                    ),
                                  );
                              
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text('No hay plazas');
                            } else {
                              final plazas = snapshot.data!;

                              return FutureBuilder<List<dynamic>>(
                                future: solicitudeslist,
                                builder: (context, solicitudesSnapshot) {
                                  if (solicitudesSnapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (solicitudesSnapshot.hasError) {
                                    return Text('Error: ${solicitudesSnapshot.error}');
                                  } else if (!solicitudesSnapshot.hasData || solicitudesSnapshot.data!.isEmpty) {
                                    
                                    return
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 32),
                                          child: Column(
                                            children: const [
                                              Icon(Icons.assignment_outlined, color: Color(0xFFEE4D00), size: 54),
                                              SizedBox(height: 12),
                                              Text(
                                                'No tienes plazas solicitadas',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Color(0xFFEE4D00),
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                '¡Aplica a plazas para verlas aquí!',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black54,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );

                                     
                                  } else {

                                    final solicitudes = solicitudesSnapshot.data!;

                                    final solicitudesUsuario = solicitudes.where((solicitud) => solicitud['usua_Id']== Session.usuario_id);

                                    final plazasUsuario = plazas.where((plaza) => solicitudesUsuario.any((solicitud) => solicitud['plaz_Id'] == plaza['plaz_Id']));

                                    if (plazasUsuario.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 32),
                                          child: Column(
                                            children: const [
                                              Icon(Icons.assignment_outlined, color: Color(0xFFEE4D00), size: 54),
                                              SizedBox(height: 12),
                                              Text(
                                                'No tienes plazas solicitadas',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Color(0xFFEE4D00),
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                '¡Aplica a plazas para verlas aquí!',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black54,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    // Aquí puedes filtrar las plazas usando los guardados si lo deseas
                                    return Column(
                                      children: plazasUsuario.map((plaza) =>
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 300,
                                                child: Card(
                                                  color: const Color(0xFFFFF3E0),
                                                  shape: const BeveledRectangleBorder(
                                                    borderRadius: BorderRadius.zero,
                                                  ),
                                                  elevation: 6,
                                                  margin: const EdgeInsets.only(bottom: 25, left: 8, right: 8),
                                                  child: Row(
                                                    children: [
                                                      // ...existing image and info code...
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.zero,
                                                        child: Image.network(
                                                          plaza['plaz_Imagen'] ?? '',
                                                          width: 150,
                                                          height: 300,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) => Container(
                                                            width: 150,
                                                            height: 300,
                                                            color: Colors.grey[300],
                                                            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                plaza['plaz_Descripcion'] ?? 'Sin título',
                                                                style: const TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Color(0xFFEE4D00),
                                                                  letterSpacing: 0.5,
                                                                ),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                plaza['plaz_Informacion'] ?? '',
                                                                style: const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors.black87,
                                                                ),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              const SizedBox(height: 8),
                                                              Row(
                                                                children: [
                                                                  const Icon(Icons.location_city, color: Colors.grey, size: 18),
                                                                  const SizedBox(width: 6),
                                                                  Expanded(
                                                                    child: Text(
                                                                      plaza['muni_Descripcion'] ?? 'Municipio',
                                                                      style: const TextStyle(
                                                                        fontSize: 15,
                                                                        color: Colors.black87,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 6),
                                                              Row(
                                                                children: [
                                                                  const Icon(Icons.category, color: Colors.grey, size: 18),
                                                                  const SizedBox(width: 6),
                                                                  Expanded(
                                                                    child: Text(
                                                                      plaza['cate_Descripcion'] ?? 'Categoría',
                                                                      style: const TextStyle(
                                                                        fontSize: 15,
                                                                        color: Colors.black87,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 6),
                                                              Row(
                                                                children: [
                                                                  const Icon(Icons.work, color: Colors.grey, size: 18),
                                                                  const SizedBox(width: 6),
                                                                  Expanded(
                                                                    child: Text(
                                                                      plaza['carg_Descripcion'] ?? 'Cargo',
                                                                      style: const TextStyle(
                                                                        fontSize: 15,
                                                                        color: Colors.black87,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Spacer(),
                                                              SizedBox(
                                                                width: double.infinity,
                                                                child: ElevatedButton(
                                                                  onPressed: () {
                                                                    Session.plaza_Id = plaza['plaz_Id'].toString();
                                                                    Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(builder: (context) => VerPlazaScreen()),
                                                                    );
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: const Color(0xFFEE4D00),
                                                                    foregroundColor: Colors.white,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(4),
                                                                    ),
                                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                                  ),
                                                                  child: const Text(
                                                                    'Más Informacion',
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 15,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).toList(),
                                    );
                                  }
                                },
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
                                color: _mensaje.contains('Bienvenido')||_mensaje.toLowerCase().contains('publicada')
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