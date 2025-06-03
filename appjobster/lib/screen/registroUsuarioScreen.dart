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
  
  // Rol del usuario (Nuevo)
  int _selectedRol = 3; // Por defecto, Buscador de trabajo (3)

  // Lists for dropdowns (replace with your service/future if needed)
  late final Future<List<dynamic>> estadosCivilesList;
  late final Future<List<dynamic>> municipiosList;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _cargando = false;
  String _mensaje = '';
  
  // Stepper control
  int _currentStep = 0;

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
          _selectedMunicipioId,
          _selectedRol // Ahora usa el rol seleccionado (3 o 4)
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

  // Método para continuar al siguiente paso
  void _nextStep() {
    if (_currentStep < 3) { // Ahora hay 4 pasos en total (0-3)
      setState(() {
        _currentStep += 1;
      });
    } else {
      _registrarUsuario();
    }
  }

  // Método para volver al paso anterior
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B00);

    return Scaffold(
     appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/JobsterBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 5),
            
              const Text(
                'Registrate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              
              // Stepper indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildStepperDot(0, 'Rol'),
                    _buildStepperLine(),
                    _buildStepperDot(1, 'Cuenta'),
                    _buildStepperLine(),
                    _buildStepperDot(2, 'Personal'),
                    _buildStepperLine(),
                    _buildStepperDot(3, 'Contacto'),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Content based on current step
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Card(
                        color: const Color.fromARGB(255, 255, 232, 223).withOpacity(0.85),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Mostrar contenido según el paso actual
                              if (_currentStep == 0)
                                _buildStep0Content(), // Nuevo paso para selección de rol
                              if (_currentStep == 1)
                                _buildStep1Content(),
                              if (_currentStep == 2)
                                _buildStep2Content(),
                              if (_currentStep == 3)
                                _buildStep3Content(),
                                
                              const SizedBox(height: 20),
                              
                              // Navigation buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_currentStep > 0)
                                    ElevatedButton(
                                      onPressed: _previousStep,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Anterior'),
                                    )
                                  else
                                    const SizedBox(),
                                  
                                  ElevatedButton(
                                    onPressed: _cargando ? null : _nextStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
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
                                        : Text(_currentStep == 3 ? 'Registrarse' : 'Siguiente'),
                                  ),
                                ],
                              ),
                              
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
            ],
          ),
        ),
      ),
    );
  }
  
  // Métodos para construir los componentes del stepper
  Widget _buildStepperDot(int step, String label) {
    bool isActive = _currentStep >= step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFF6B00) : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (step + 1).toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepperLine() {
    return const Expanded(
      child: Divider(
        color: Colors.grey,
        thickness: 2,
      ),
    );
  }
  
  // Contenido del paso inicial - Selección de rol
  Widget _buildStep0Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¿Qué rol tendrás en Jobster?',
          style: TextStyle(
            color: Color(0xFFFF6B00),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        
        // Botón para Buscador de trabajo
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedRol = 3; // Código para Buscador de trabajo
            });
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _selectedRol == 3 
                ? const Color(0xFFFF6B00).withOpacity(0.2) 
                : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _selectedRol == 3 
                  ? const Color(0xFFFF6B00) 
                  : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_outlined,
                  size: 60,
                  color: _selectedRol == 3 
                    ? const Color(0xFFFF6B00) 
                    : Colors.grey,
                ),
                const SizedBox(height: 15),
                Text(
                  'Buscador de Trabajo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _selectedRol == 3 
                      ? const Color(0xFFFF6B00) 
                      : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Encontrarás oportunidades laborales según tus habilidades',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Botón para Publicador de trabajo
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedRol = 4; // Código para Publicador de trabajo
            });
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _selectedRol == 4 
                ? const Color(0xFFFF6B00).withOpacity(0.2) 
                : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _selectedRol == 4 
                  ? const Color(0xFFFF6B00) 
                  : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.business_center_outlined,
                  size: 60,
                  color: _selectedRol == 4 
                    ? const Color(0xFFFF6B00) 
                    : Colors.grey,
                ),
                const SizedBox(height: 15),
                Text(
                  'Publicador de Trabajo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _selectedRol == 4 
                      ? const Color(0xFFFF6B00) 
                      : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Podrás crear ofertas de trabajo y encontrar candidatos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Contenido del primer paso - Información de cuenta
  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Información de Cuenta',
          style: TextStyle(
            color: Color(0xFFFF6B00),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
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
        Center(
          child: GestureDetector(
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
        ),
      ],
    );
  }
  
  // Contenido del segundo paso - Información personal
  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Datos Personales',
          style: TextStyle(
            color: Color(0xFFFF6B00),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
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
        ),
        const SizedBox(height: 16),
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
          fillColor: _persSexo == 'M' 
              ? const Color.fromARGB(255, 38, 107, 255) 
              : const Color.fromARGB(255, 255, 38, 161),
          color: Colors.black87,
          constraints: const BoxConstraints(minHeight: 40, minWidth: 165),
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
      ],
    );
  }
  
  // Contenido del tercer paso - Información de contacto
  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Datos de Contacto',
          style: TextStyle(
            color: Color(0xFFFF6B00),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
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
              );
            }
          },
        ),
      ],
    );
  }
}