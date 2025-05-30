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

class PublicarPlazaScreen extends StatefulWidget {
  const PublicarPlazaScreen({super.key});

  @override
  State<PublicarPlazaScreen> createState() => _PublicarPlazaScreenState();
}

class _PublicarPlazaScreenState extends State<PublicarPlazaScreen> {
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

  bool _cargando = false;
  final bool _obscureText = true;
  final bool _rememberMe = false;
  String _mensaje = '';

  @override
  void initState() {
    super.initState();
    cargosList = _plazaService.getCargos();
    categoriasList = _plazaService.getCategorias();
    municipiosList = _plazaService.getMunicipios();
    tiposContratoList = _plazaService.getTiposContrato();
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  File? _selectedImage;
  
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

void _publicarPlaza() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _cargando = true;
      _mensaje = '';
    });

    try {
      // 1. Check if image is selected
      if (_selectedImage == null) {
        setState(() {
          _mensaje = 'Por favor seleccione una imagen para la plaza';
          _cargando = false;
        });
        return;
      }

      // 2. Upload image to Cloudinary
      final url = Uri.parse('https://api.cloudinary.com/v1_1/dw2aj3hcu/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'unsignedig'
        ..files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final resJson = json.decode(resStr);
        final imageUrl = resJson['secure_url'];

        // 3. Use imageUrl in your plaza creation
        final respuesta = await _plazaService.crearPlaza(
          _tituloController.text.trim(),
          _informacionController.text.trim(),
          imageUrl, // Use the Cloudinary URL here
          _direccionController.text.trim(),
          _selectedCategoriaId,
          _selectedCargoId,
          _selectedTipoContratoId,
        );

        if (respuesta.toString().toLowerCase().contains('creada')) {
          setState(() {
            _mensaje = 'Plaza Publicada con éxito';
          });
        } else {
          setState(() {
            _mensaje = 'Error al publicar la plaza: $respuesta';
            _cargando = false;
          });
        }
      } else {
        setState(() {
          _mensaje = 'Error al subir la imagen al Servidor';
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'ERROR AL PUBLICAR PLAZA $e';
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
          color: Color.fromARGB(255, 255, 134, 42),
          // color: Color.fromARGB(255, 225, 129, 19)
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
                        const SizedBox(height: 16),

                        const Text(
                          'Imagen De La Plaza',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        GestureDetector(
                          onTap: _pickImage,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16), // Adjust the radius as needed
                            child: _selectedImage == null
                                ? Container(
                                    height: 120,
                                    width: 120,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.add_photo_alternate_outlined, size: 40),
                                  )
                                : Image.file(
                                    _selectedImage!,
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),

                        // GestureDetector(
                        //   onTap: _pickImage,
                        //   child: _selectedImage == null
                        //       ? Container(
                        //           height: 120,
                        //           width: 120,
                        //           color: Colors.grey[300],
                        //           child: const Icon(Icons.insert_photo, size: 40),
                        //         )
                        //       : Image.file(
                        //           _selectedImage!,
                        //           height: 120,
                        //           width: 120,
                        //           fit: BoxFit.cover,
                        //         ),
                        // ),

                        // const SizedBox(height: 16),
                        // Transform.translate(
                        //   offset: const Offset(0, -30),
                        //   child: Image.asset(
                        //     'assets/logo_blanco.png',
                        //     height: 100,
                        //   ),
                        // ),
                        // const SizedBox(height: 10),
                        const SizedBox(height: 16),

                        const Text(
                          'Titulo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        TextFormField(
                          controller: _tituloController,
                          // keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText:
                                'Titulo de La Plaza. ej: Desarrollador Web',
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
                              return 'Por favor ingrese un titulo para la Plaza';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Informacion Detallada',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        TextFormField(
                          maxLines: 5,
                          controller: _informacionController,
                          decoration: InputDecoration(
                            hintText: '',
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
                              return 'Por favor ingrese la informacion de la Plaza';
                            }
                            return null;
                          },
                        ),
                        ////
                        const SizedBox(height: 16),

                        const Text(
                          'Direccion',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        TextFormField(
                          controller: _direccionController,

                          decoration: InputDecoration(
                            hintText: 'Avenida X, Calle Y, Local Z',
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
                              return 'Por favor ingrese su Direccion';
                            }
                            return null;
                          },
                        ),
                        ////
                        const SizedBox(height: 16),

                        const Text(
                          'Cargos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        FutureBuilder<List<dynamic>>(
                          future: cargosList,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Text('No hay cargos disponibles');
                            } else {
                              final cargos = snapshot.data!;
                              return DropdownButtonFormField<int>(
                                value: _selectedCargoId,
                                decoration: InputDecoration(
                                  labelText: 'Cargo',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: cargos.map<DropdownMenuItem<int>>((
                                  cargo,
                                ) {
                                  return DropdownMenuItem<int>(
                                    value: cargo['carg_Id'],
                                    child: Text(cargo['carg_Descripcion']),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCargoId = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'Por favor seleccione un cargo'
                                    : null,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Categoria',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        FutureBuilder<List<dynamic>>(
                          future: categoriasList,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Text(
                                'No hay categorías disponibles',
                              );
                            } else {
                              final categorias = snapshot.data!;
                              return DropdownButtonFormField<int>(
                                value:
                                    _selectedCategoriaId, // Define this variable in your State
                                decoration: InputDecoration(
                                  labelText: 'Categoria',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: categorias.map<DropdownMenuItem<int>>((
                                  categoria,
                                ) {
                                  return DropdownMenuItem<int>(
                                    value: categoria['cate_Id'],
                                    child: Text(categoria['cate_Descripcion']),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategoriaId = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'Por favor seleccione una categoría'
                                    : null,
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Tipo de Contrato',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        FutureBuilder<List<dynamic>>(
                          future: tiposContratoList,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Text(
                                'No hay tipos de contrato disponibles',
                              );
                            } else {
                              final tiposContrato = snapshot.data!;
                              return DropdownButtonFormField<int>(
                                value:
                                    _selectedTipoContratoId, // Asegúrate de definir esto en tu State
                                decoration: InputDecoration(
                                  labelText: 'Tipo de Contrato',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: tiposContrato.map<DropdownMenuItem<int>>(
                                  (tipo) {
                                    return DropdownMenuItem<int>(
                                      value: tipo['tiCo_Id'],
                                      child: Text(tipo['tiCo_Descripcion']),
                                    );
                                  },
                                ).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTipoContratoId = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'Por favor seleccione un tipo de contrato'
                                    : null,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _cargando ? null : _publicarPlaza,
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
                                  'Publicar',
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
