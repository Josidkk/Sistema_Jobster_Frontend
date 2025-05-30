// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

// import 'package:appjobster/models/usuarioViewModel.dart';
// import 'package:appjobster/services/usuarioService.dart';
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
  late final plazasList ;
  


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

                        // Column(
                        //   children:  plazasList.map( (plaza) => 
                        //   Card(

                        //     child: Row(

                        //       children: [

                        //         Text(plaza.plaz_Descripcion)
                        //       ],

                        //     ),

                        //   ),
                        //   ).toList() 
                        //   ),
                        
                        FutureBuilder<List<dynamic>>(
                          future: plazasList,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text('No hay plazas');
                            } else {
                              final plazas = snapshot.data!;
                              
                              return Column(
                                children: plazas.map((plaza) => 
                                
                                Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 300,
                                      child: Card(
                                          color: Color(0xFFEE4D00),
                                          // color: const Color.fromARGB(255, 255, 106, 47).withOpacity(0.85), 
                                          // color: const Color.fromARGB(255, 255, 221, 206).withOpacity(0.85), 
                                          shape: BeveledRectangleBorder(
                                            
                                            borderRadius: BorderRadius.circular(0),
                                          ),
                                          elevation: 0,
                                          margin: const EdgeInsets.only(bottom: 25, left: 0, right: 0),
                                          // child: Text(plaza['plaz_Descripcion']),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 16),

                                              // Row(
                                              //   children: [
                                              //     Card(
                                                    
                                              //       margin: EdgeInsetsGeometry.only(left: 0, right: 0),
                                                    
                                              //       child: Text(plaza['plaz_Descripcion'],
                                              //               textWidthBasis: TextWidthBasis.parent,
                                              //               textScaler: TextScaler.linear(1.5),
                                              //               textAlign: TextAlign.right,
                                              //               ),
                                              //     )
                                              //   ],
                                              // ),
                                              
                                               Center(
                                                child: Card(
                                                  
                                                  color: const Color.fromARGB(255, 202, 202, 202),
                                                  elevation: 4,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(0),
                                                  ),
                                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                                    child: SizedBox(
                                                      width: MediaQuery.of(context).size.width, // or double.infinity for full width inside margin
                                                      child: Text(
                                                        plaza['plaz_Descripcion'] ?? '',
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),


                                              ClipRRect(
                                                borderRadius: BorderRadius.zero, // squared corners
                                                child: Image.network(
                                                  plaza['plaz_Imagen'] ?? '',
                                                  width: 400,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[300],
                                                    child: const Icon(Icons.broken_image, size: 32),
                                                  ),
                                                ),
                                              )


                                              // ElevatedButton(
                                              //   onPressed: onPressed,
                                              //   child: child)

                                            ],
                                          )
                                    )
                                  ,
                                      
                                    )
                                  
                                  ],
                                )
                                
                                ).toList(),

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
