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

class MisPlazasScreen extends StatefulWidget {
  const MisPlazasScreen({super.key});

  @override
  State<MisPlazasScreen> createState() => _MisPlazasScreenState();
}

class _MisPlazasScreenState extends State<MisPlazasScreen> {
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

  // void _iniciarSesion() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _cargando = true;
  //       _mensaje = '';
  //     });

  //     try {
  //       final Usuario? usuario = await _usuarioService.login(
  //         _usuarioController.text.trim(),
  //         _contrasenaController.text.trim(),
  //       );
  //       if (usuario != null) {
  //         setState(() {
  //           _mensaje = 'Bienvenido';
  //         });
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => const principalScreen()),
  //         );
  //       } else {
  //         setState(() {
  //           _mensaje = 'Usuario o contraseña incorrectos';
  //           _cargando = false;
  //         });
  //       }
  //     } catch (e) {
  //       setState(() {
  //         _mensaje = 'ERROR AL INICIAR SESION $e';
  //         _cargando = false;
  //       });
  //     } finally {
  //       setState(() {
  //         _cargando = false;
  //       });
  //     }
  //   }
  // }

  // void _publicarPlaza() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _cargando = true;
  //       _mensaje = '';
  //     });

  //     try {
  //       // if (_selectedImage == null) {
  //       //   setState(() {
  //       //     _mensaje = 'Por favor seleccione una imagen para la plaza';
  //       //     _cargando = false;
  //       //   });
  //       //   return;
  //       // }


          


  //       final respuesta = await _plazaService.crearPlaza(
  //         _tituloController.text.trim(),
  //         _informacionController.text.trim(),
  //         '_selectedImage',
  //         _direccionController.text.trim(),
  //         _selectedCategoriaId,
  //         _selectedCargoId,
  //         _selectedTipoContratoId,

  //         // _usuarioController.text.trim(),
  //         // _contrasenaController.text.trim(),
  //       );
  //       if (respuesta.toString().toLowerCase().contains('creada')) {
  //         setState(() {
  //           _mensaje = 'Plaza Publicada con éxito';
  //         });
  //         // Navigator.pushReplacement(
  //         //   context,
  //         //   MaterialPageRoute(builder: (context) => const principalScreen()),
  //         // );
  //       } else {
  //         setState(() {
  //           _mensaje = 'Error al publicar la plaza: $respuesta';
  //           _cargando = false;
  //         });
  //       }
  //     } catch (e) {
  //       setState(() {
  //         _mensaje = 'ERROR AL INICIAR SESION $e';
  //         _cargando = false;
  //       });
  //     } finally {
  //       setState(() {
  //         _cargando = false;
  //       });
  //     }
  //   }
  // }

// void _publicarPlaza() async {
//   if (_formKey.currentState!.validate()) {
//     setState(() {
//       _cargando = true;
//       _mensaje = '';
//     });

//     try {
//       // 1. Check if image is selected
//       if (_selectedImage == null) {
//         setState(() {
//           _mensaje = 'Por favor seleccione una imagen para la plaza';
//           _cargando = false;
//         });
//         return;
//       }

//       // 2. Upload image to Cloudinary
//       final url = Uri.parse('https://api.cloudinary.com/v1_1/dw2aj3hcu/image/upload');
//       final request = http.MultipartRequest('POST', url)
//         ..fields['upload_preset'] = 'unsignedig'
//         ..files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));

//       final response = await request.send();

//       if (response.statusCode == 200) {
//         final resStr = await response.stream.bytesToString();
//         final resJson = json.decode(resStr);
//         final imageUrl = resJson['secure_url'];

//         // 3. Use imageUrl in your plaza creation
//         final respuesta = await _plazaService.crearPlaza(
//           _tituloController.text.trim(),
//           _informacionController.text.trim(),
//           imageUrl, // Use the Cloudinary URL here
//           _direccionController.text.trim(),
//           _selectedCategoriaId,
//           _selectedCargoId,
//           _selectedTipoContratoId,
//         );

//         if (respuesta.toString().toLowerCase().contains('creada')) {
//           setState(() {
//             _mensaje = 'Plaza Publicada con éxito';
//           });
//         } else {
//           setState(() {
//             _mensaje = 'Error al publicar la plaza: $respuesta';
//             _cargando = false;
//           });
//         }
//       } else {
//         setState(() {
//           _mensaje = 'Error al subir la imagen al Servidor';
//           _cargando = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _mensaje = 'ERROR AL PUBLICAR PLAZA $e';
//         _cargando = false;
//       });
//     } finally {
//       setState(() {
//         _cargando = false;
//       });
//     }
//   }
// }

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
                              return Center(
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
                                      'Cargando plazas...',
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

                              final plazasUsuario = plazas.where((plaza) => plaza['usua_Id'] == Session.usuario_id).toList();
                              
                              return Column(
                                children: plazasUsuario.map((plaza) => 
                                
                                // Row(
                                //   children: [
                                //     SizedBox(
                                //       width: MediaQuery.of(context).size.width,
                                //       height: 300,
                                //       child: Card(
                                //           color: Color(0xFFEE4D00),
                                //           // color: const Color.fromARGB(255, 255, 106, 47).withOpacity(0.85), 
                                //           // color: const Color.fromARGB(255, 255, 221, 206).withOpacity(0.85), 
                                //           shape: BeveledRectangleBorder(
                                            
                                //             borderRadius: BorderRadius.circular(0),
                                //           ),
                                //           elevation: 0,
                                //           margin: const EdgeInsets.only(bottom: 25, left: 0, right: 0),
                                //           // child: Text(plaza['plaz_Descripcion']),
                                //           child: Column(
                                //             children: [
                                //               const SizedBox(height: 16),
                                              
                                //                Center(
                                //                 child: Card(
                                                  
                                //                   color: const Color.fromARGB(255, 202, 202, 202),
                                //                   elevation: 4,
                                //                   shape: RoundedRectangleBorder(
                                //                     borderRadius: BorderRadius.circular(0),
                                //                   ),
                                //                   margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                //                   child: Padding(
                                //                     padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                //                     child: SizedBox(
                                //                       width: MediaQuery.of(context).size.width, // or double.infinity for full width inside margin
                                //                       child: Text(
                                //                         plaza['plaz_Descripcion'] ?? '',
                                //                         textAlign: TextAlign.center,
                                //                         style: const TextStyle(
                                //                           fontSize: 20,
                                //                           fontWeight: FontWeight.bold,
                                //                         ),
                                //                         maxLines: 1,
                                //                         overflow: TextOverflow.ellipsis,
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 ),
                                //               ),


                                //               ClipRRect(
                                //                 borderRadius: BorderRadius.zero, // squared corners
                                //                 child: Image.network(
                                //                   plaza['plaz_Imagen'] ?? '',
                                //                   width: 400,
                                //                   height: 150,
                                //                   fit: BoxFit.cover,
                                //                   errorBuilder: (context, error, stackTrace) => Container(
                                //                     width: 80,
                                //                     height: 80,
                                //                     color: Colors.grey[300],
                                //                     child: const Icon(Icons.broken_image, size: 32),
                                //                   ),
                                //                 ),
                                //               )


                                //               // ElevatedButton(
                                //               //   onPressed: onPressed,
                                //               //   child: child)

                                //             ],
                                //           )
                                //     )
                                //   ,
                                      
                                //     )
                                  
                                //   ],
                                // )

Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: SizedBox(
        height: 300,
        child: Card(
          color: const Color(0xFFFFF3E0),
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.zero, // No rounded corners
          ),
          elevation: 6,
          margin: const EdgeInsets.only(bottom: 25, left: 8, right: 8),
          child: Row(
            children: [
              // Image section
              ClipRRect(
                borderRadius: BorderRadius.zero, // No rounded corners
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
              // Info section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Title
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
                      // Information (large text, max 4 lines)
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
                      // Municipio
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
                      // Categoria
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
                      // Cargo
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
                      // Button with less height
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            
                            Session.plaza_Id = plaza['plaz_Id'].toString() ;
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
                            padding: const EdgeInsets.symmetric(vertical: 8), // Less height
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
