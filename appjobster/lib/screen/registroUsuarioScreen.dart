import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jobster/screen/loginScreen.dart';
import 'dart:io';
import '../services/plazaService.dart';
import 'package:jobster/services/navigation_service.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}


class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {

  final _plazaService = PlazaService();
  // Controllers for usuario info
  final TextEditingController _usuaNombreController = TextEditingController();
  final TextEditingController _usuaContrasenaController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  // Controllers for persona info
  final TextEditingController _persDNIController = TextEditingController();
  final TextEditingController _persNombresController = TextEditingController();
  final TextEditingController _persApellidosController = TextEditingController();
  final TextEditingController _persTelefonoController = TextEditingController();
  final TextEditingController _persDireccionController = TextEditingController();

  // Image for usuario
  File? _selectedUsuaImagen;

  // Dropdown values
  int? _selectedEstadoCivilId;
  String? _selectedMunicipioId;
  String? _persSexo; // 'M' or 'F'

  // Lists for dropdowns (replace with your service/future if needed)
  late final Future<List<dynamic>> estadosCivilesList;
  late final Future<List<dynamic>> municipiosList;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _cargando = false;
  String _mensaje = '';

  @override
  void initState() {
    super.initState();
    // Replace with your service calls if needed
    estadosCivilesList = _plazaService.getEstadosCiviles();
    municipiosList = _plazaService.getMunicipios();
  }

  // Dummy data for dropdowns (replace with your API/service)
  Future<List<dynamic>> getEstadosCiviles() async {
    return [
      {'esCi_Id': 1, 'esCi_Descripcion': 'Soltero'},
      {'esCi_Id': 2, 'esCi_Descripcion': 'Casado'},
      {'esCi_Id': 3, 'esCi_Descripcion': 'Divorciado'},
    ];
  }

  // Future<List<dynamic>> getMunicipios() async {
  //   return [
  //     {'muni_Codigo': '0501', 'muni_Descripcion': 'Municipio 1'},
  //     {'muni_Codigo': '0501', 'muni_Descripcion': 'Municipio 2'},
  //     {'muni_Codigo': '0501', 'muni_Descripcion': 'Municipio 3'},
  //   ];
  // }

  Future<void> _pickUsuaImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedUsuaImagen = File(pickedFile.path);
      });
    }
  }

  void _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _cargando = true;
        _mensaje = '';
      });

      try {

          if (_selectedUsuaImagen == null) {
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
          ..files.add(await http.MultipartFile.fromPath('file', _selectedUsuaImagen!.path));

        final response = await request.send();

        if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final resJson = json.decode(resStr);
        final imageUrl = resJson['secure_url'];

        // 3. Use imageUrl in your plaza creation
        final respuesta = await _plazaService.crearPersonaUsuario(
          _usuaNombreController.text.trim(),
          _usuaContrasenaController.text.trim(),
          _correoController.text.trim(),
          imageUrl,
          _persDNIController.text.trim(),
          _persNombresController.text.trim(),
          _persApellidosController.text.trim(),
          _persTelefonoController.text.trim(),
          _persSexo,
          _persDireccionController.text.trim(),
          _selectedEstadoCivilId,
          _selectedMunicipioId
        );

        if (respuesta.toString().toLowerCase().contains('creada')) {
          setState(() {

               

 NavigationService.navigateWithSlide(
                          context,
                          const LoginScreen(),
                        );

            _mensaje = 'Usuario Registrado con éxito';
          });
        } else {
          setState(() {
            _mensaje = 'Error al Registrar Usuario: $respuesta';
            _cargando = false;
          });
        }
      } else {
        setState(() {
          _mensaje = 'Error al subir la imagen al Servidor';
          _cargando = false;
        });
      }


        /////////////////////////////////////////
        setState(() {
          _mensaje = 'Usuario registrado con éxito';
        });
      } catch (e) {
        setState(() {
          _mensaje = 'Error al registrar usuario: $e';
        });
      } finally {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usuaNombreController.dispose();
    _usuaContrasenaController.dispose();
    _correoController.dispose();
    _persDNIController.dispose();
    _persNombresController.dispose();
    _persApellidosController.dispose();
    _persTelefonoController.dispose();
    _persDireccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B00);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro de Usuario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      Transform.translate(
                          offset: const Offset(0, 0),
                          child: Image.asset(
                            'assets/logo_blanco.png',
                            height: 100,
                          ),
                        ),
                        

                        const Text(
                          'Registrate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                      // Usuario Info Card (rounded)
                      Card(
                        color: const Color.fromARGB(255, 255, 232, 223).withOpacity(0.85), 
                        // color: const Color.fromARGB(255, 255, 221, 206).withOpacity(0.85), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                textAlign: TextAlign.center,
                                'Datos del Usuario',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Foto de Perfil',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: _pickUsuaImage,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: _selectedUsuaImagen == null
                                      ? Container(
                                          height: 120,
                                          width: 120,
                                          color: Colors.white,
                                          child: const Icon(Icons.add_photo_alternate_outlined, size: 40),
                                        )
                                      : Image.file(
                                          _selectedUsuaImagen!,
                                          height: 120,
                                          width: 120,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nombre de Usuario',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _usuaNombreController,
                                decoration: InputDecoration(
                                  hintText: 'Ingrese el nombre de usuario',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: UnderlineInputBorder(
                                    
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el nombre de usuario';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Contraseña',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _usuaContrasenaController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Ingrese la contraseña',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese la contraseña';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Correo Electrónico',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _correoController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Ingrese el correo electrónico',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el correo electrónico';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Ingrese un correo válido';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Persona Info Card (rounded)
                      Card(
                        color: const Color.fromARGB(255, 255, 232, 223).withOpacity(0.85), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                textAlign: TextAlign.center,
                                'Datos Personales',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'DNI',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _persDNIController,
                                decoration: InputDecoration(
                                  hintText: 'Ingrese el DNI',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el DNI';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nombres',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _persNombresController,
                                decoration: InputDecoration(
                                  hintText: 'Ingrese los nombres',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese los nombres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Apellidos',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _persApellidosController,
                                decoration: InputDecoration(
                                  hintText: 'Ingrese los apellidos',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese los apellidos';
                                  }
                                  return null;
                                },
                              ),

                              //inicio sexos
                              const SizedBox(height: 16),

                              // const Text(
                              //   'Sexo',
                              //   style: TextStyle(
                              //     color: Colors.black87,
                              //     fontSize: 14,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              // const SizedBox(height: 4),
                              // DropdownButtonFormField<String>(
                              //   value: _persSexo,
                              //   decoration: InputDecoration(
                              //     labelText: 'Seleccione el sexo',
                              //     border: UnderlineInputBorder(
                              //       borderRadius: BorderRadius.circular(8),
                              //     ),
                              //     filled: true,
                              //     fillColor: Colors.white,
                              //   ),
                              //   items: const [
                              //     DropdownMenuItem(
                              //       value: 'M',
                              //       child: Text('Masculino'),
                              //     ),
                              //     DropdownMenuItem(
                              //       value: 'F',
                              //       child: Text('Femenino'),
                              //     ),
                              //   ],
                              //   onChanged: (value) {
                              //     setState(() {
                              //       _persSexo = value;
                              //     });
                              //   },
                              //   validator: (value) =>
                              //       value == null ? 'Seleccione el sexo' : null,
                              // ),
                              
                              
                              // ...existing code...
                              const Text(
                                'Sexo',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ToggleButtons(
                                
                                isSelected: [
                                  _persSexo == 'M',
                                  _persSexo == 'F',
                                ],
                                onPressed: (index) {
                                  setState(() {
                                    _persSexo = index == 0 ? 'M' : 'F';
                                  });
                                },
                                
                                borderRadius: BorderRadius.circular(8),
                                selectedColor: Colors.white,
                                // fillColor: Colors.orange.shade400,
                                fillColor: _persSexo == 'M'? const Color.fromARGB(255, 38, 107, 255) : const Color.fromARGB(255, 255, 38, 161),
                                color: Colors.black87,
                                constraints: const BoxConstraints(minHeight: 40, minWidth: 165 ),
                                children: const [
                                  Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.man_sharp),
                                          Text('Masculino')
                                        ],
                                      )
                                      
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.woman_sharp),
                                          Text('Femenino')                                          
                                        ],
                                      )
                                        
                                      ],
                                  ),
                                
                                  
                                  
                                ],
                              ),
                              if (_persSexo == null && !_cargando)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, top: 2),
                                  child: Text(
                                    'Seleccione el sexo',
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                              
                              
                              //fin perssexos
                              const SizedBox(height: 16),
                              const Text(
                                'Teléfono',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _persTelefonoController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Ingrese el teléfono',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el teléfono';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Dirección',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _persDireccionController,
                                decoration: InputDecoration(
                                  hintText: 'Ingrese la dirección',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese la dirección';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Estado Civil',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FutureBuilder<List<dynamic>>(
                                future: estadosCivilesList,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Text('No hay estados civiles disponibles');
                                  } else {
                                    final estados = snapshot.data!;
                                    return DropdownButtonFormField<int>(
                                      value: _selectedEstadoCivilId,
                                      decoration: InputDecoration(
                                        labelText: 'Seleccione un estado civil',
                                        border: UnderlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      items: estados.map<DropdownMenuItem<int>>((estado) {
                                        return DropdownMenuItem<int>(
                                          value: estado['esCi_Id'],
                                          child: Text(estado['esCi_Descripcion']),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedEstadoCivilId = value;
                                        });
                                      },
                                      validator: (value) =>
                                          value == null ? 'Seleccione un estado civil' : null,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Municipio',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FutureBuilder<List<dynamic>>(
                                future: municipiosList,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Text('No hay municipios disponibles');
                                  } else {
                                    final municipios = snapshot.data!;
                                    return DropdownButtonFormField<String>(
                                      value: _selectedMunicipioId,
                                      decoration: InputDecoration(
                                        labelText: 'Seleccione un municipio',
                                        border: UnderlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      items: municipios.map<DropdownMenuItem<String>>((muni) {
                                        return DropdownMenuItem<String>(
                                          value: muni['muni_Codigo'],
                                          child: Text(muni['muni_Descripcion']),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedMunicipioId = value;
                                        });
                                      },
                                      validator: (value) =>
                                          value == null ? 'Seleccione un municipio' : null,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: _cargando ? null : _registrarUsuario ,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 100),
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
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Registrarse',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),

                      // ElevatedButton(
                      //   onPressed: _cargando ? null : _registrarUsuario,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: primaryColor,
                      //     foregroundColor: Colors.white,
                      //     padding: const EdgeInsets.symmetric(vertical: 16),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     elevation: 0,
                      //     disabledBackgroundColor: primaryColor.withOpacity(0.7),
                      //   ),
                      //   child: _cargando
                      //       ? const SizedBox(
                      //           height: 20,
                      //           width: 20,
                      //           child: CircularProgressIndicator(
                      //             strokeWidth: 2,
                      //             color: Colors.white,
                      //           ),
                      //         )
                      //       : const Text(
                      //           'Registrar',
                      //           style: TextStyle(
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      // ),
                      const SizedBox(height: 30),

                      if (_mensaje.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _mensaje,
                            style: TextStyle(
                              color: _mensaje.contains('éxito')
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
    );
  }
}