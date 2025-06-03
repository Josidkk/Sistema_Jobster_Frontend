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
  String _mensaje = '';

  File? _selectedImage;

  // Section navigation
  int _currentSection = 0;

  // Requisitos array and controllers
  List<Map<String, String>> _requisitos = [];
  final TextEditingController _requDescripcionController = TextEditingController();
  final TextEditingController _requInformacionController = TextEditingController();

  // For toast/alert
  OverlayEntry? _overlayEntry;

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
    _requDescripcionController.dispose();
    _requInformacionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addRequisito() {
    final descripcion = _requDescripcionController.text.trim();
    final informacion = _requInformacionController.text.trim();
    if (descripcion.isNotEmpty && informacion.isNotEmpty) {
      setState(() {
        _requisitos.add({
          'requ_Descripcion': descripcion,
          'requ_Informacion': informacion,
        });
        _requDescripcionController.clear();
        _requInformacionController.clear();
      });
    }
  }

  void _removeRequisito(int index) {
    setState(() {
      _requisitos.removeAt(index);
    });
  }

  void _goToSection(int section) {
    setState(() {
      _currentSection = section;
      _mensaje = '';
    });
  }

  void _showToast(String message) {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.92),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 2), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _publicarPlaza() async {
    if (_formKey.currentState!.validate() && _requisitos.isNotEmpty) {
      setState(() {
        _cargando = true;
        _mensaje = '';
      });

      try {
        if (_selectedImage == null) {
          _showToast('Por favor seleccione una imagen para la plaza');
          setState(() {
            _cargando = false;
          });
          return;
        }

        final url = Uri.parse('https://api.cloudinary.com/v1_1/dw2aj3hcu/image/upload');
        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'unsignedig'
          ..files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));

        final response = await request.send();

        if (response.statusCode == 200) {
          final resStr = await response.stream.bytesToString();
          final resJson = json.decode(resStr);
          final imageUrl = resJson['secure_url'];

          final respuesta = await _plazaService.crearPlaza(
            _tituloController.text.trim(),
            _informacionController.text.trim(),
            imageUrl,
            _direccionController.text.trim(),
            _selectedCategoriaId,
            _selectedCargoId,
            _selectedTipoContratoId,
            _requisitos,
          );

          if (respuesta.toString().toLowerCase().contains('creada')) {
            setState(() {
              _mensaje = 'Plaza Publicada con éxito';
            });
          } else {
            _showToast('Error al publicar la plaza: $respuesta');
            setState(() {
              _cargando = false;
            });
          }
        } else {
          _showToast('Error al subir la imagen al Servidor');
          setState(() {
            _cargando = false;
          });
        }
      } catch (e) {
        _showToast('ERROR AL PUBLICAR PLAZA $e');
        setState(() {
          _cargando = false;
        });
      } finally {
        setState(() {
          _cargando = false;
        });
      }
    } else {
      // Show toast with missing fields
      String missing = '';
      if (_selectedImage == null) missing += 'Imagen, ';
      if (_tituloController.text.trim().isEmpty) missing += 'Título, ';
      if (_informacionController.text.trim().isEmpty) missing += 'Información, ';
      if (_direccionController.text.trim().isEmpty) missing += 'Dirección, ';
      if (_selectedCargoId == null) missing += 'Cargo, ';
      if (_selectedCategoriaId == null) missing += 'Categoría, ';
      if (_selectedTipoContratoId == null) missing += 'Tipo de Contrato, ';
      if (_requisitos.isEmpty) missing += 'Al menos un requisito, ';
      if (missing.endsWith(', ')) missing = missing.substring(0, missing.length - 2);
      _showToast('Faltan campos: $missing');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFEE4D00);
    const Color accentColor = Color(0xFF23272F);
    const Color cardColor = Color(0xFFF5F5F7);
    const Color sectionBg = Color(0xFFFFF3E0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Publicar Plaza',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Builder(
                  builder: (context) {
                    if (_currentSection == 0) {
                      // SECTION 1: Imagen, Titulo, Informacion
                      return SingleChildScrollView(
                        child: Column(
                          key: const ValueKey(0),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _sectionStepper(0),
                            Card(
                              color: sectionBg,
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _sectionTitle('Imagen de la Plaza'),
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.orange.shade200,
                                            width: 1.2,
                                          ),
                                        ),
                                        height: 110,
                                        width: double.infinity,
                                        child: _selectedImage == null
                                            ? const Center(
                                                child: Icon(Icons.add_photo_alternate_outlined, size: 38, color: accentColor),
                                              )
                                            : ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.file(
                                                  _selectedImage!,
                                                  height: 110,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _sectionTitle('Título'),
                                    _styledTextField(
                                      controller: _tituloController,
                                      hintText: 'Ej: Desarrollador Web',
                                      fontSize: 15,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingrese un título para la Plaza';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _sectionTitle('Información Detallada'),
                                    _styledTextField(
                                      controller: _informacionController,
                                      hintText: 'Describe la plaza...',
                                      maxLines: 4,
                                      fontSize: 15,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingrese la información de la Plaza';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 22),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _goToSection(1),
                                          icon: const Icon(Icons.arrow_forward),
                                          label: const Text('Siguiente'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_mensaje.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  _mensaje,
                                  style: TextStyle(
                                    color: _mensaje.contains('Bienvenido') || _mensaje.toLowerCase().contains('publicada')
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      );
                    } else if (_currentSection == 1) {
                      // SECTION 2: Dirección y dropdowns
                      return SingleChildScrollView(
                        child: Column(
                          key: const ValueKey(1),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _sectionStepper(1),
                            Card(
                              color: sectionBg,
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _sectionTitle('Dirección'),
                                    _styledTextField(
                                      controller: _direccionController,
                                      hintText: 'Avenida X, Calle Y, Local Z',
                                      fontSize: 15,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingrese la dirección';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _sectionTitle('Cargo'),
                                    FutureBuilder<List<dynamic>>(
                                      future: cargosList,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const LinearProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Text('No hay cargos disponibles');
                                        } else {
                                          final cargos = snapshot.data!;
                                          return DropdownButtonFormField<int>(
                                            value: _selectedCargoId,
                                            decoration: _dropdownDecoration('Cargo'),
                                            items: cargos.map<DropdownMenuItem<int>>((cargo) {
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
                                            validator: (value) => value == null ? 'Por favor seleccione un cargo' : null,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _sectionTitle('Categoría'),
                                    FutureBuilder<List<dynamic>>(
                                      future: categoriasList,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const LinearProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Text('No hay categorías disponibles');
                                        } else {
                                          final categorias = snapshot.data!;
                                          return DropdownButtonFormField<int>(
                                            value: _selectedCategoriaId,
                                            decoration: _dropdownDecoration('Categoría'),
                                            items: categorias.map<DropdownMenuItem<int>>((categoria) {
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
                                            validator: (value) => value == null ? 'Por favor seleccione una categoría' : null,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _sectionTitle('Tipo de Contrato'),
                                    FutureBuilder<List<dynamic>>(
                                      future: tiposContratoList,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const LinearProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Text('No hay tipos de contrato disponibles');
                                        } else {
                                          final tiposContrato = snapshot.data!;
                                          return DropdownButtonFormField<int>(
                                            value: _selectedTipoContratoId,
                                            decoration: _dropdownDecoration('Tipo de Contrato'),
                                            items: tiposContrato.map<DropdownMenuItem<int>>((tipo) {
                                              return DropdownMenuItem<int>(
                                                value: tipo['tiCo_Id'],
                                                child: Text(tipo['tiCo_Descripcion']),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedTipoContratoId = value;
                                              });
                                            },
                                            validator: (value) => value == null ? 'Por favor seleccione un tipo de contrato' : null,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 22),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _goToSection(0),
                                          icon: const Icon(Icons.arrow_back),
                                          label: const Text('Atrás'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accentColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => _goToSection(2),
                                          icon: const Icon(Icons.arrow_forward),
                                          label: const Text('Siguiente'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // SECTION 3: Requisitos
                      return SingleChildScrollView(
                        child: Column(
                          key: const ValueKey(2),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _sectionStepper(2),
                            Card(
                              color: sectionBg,
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                child: Column(
                                  children: [
                                    _sectionTitle('Requisitos de la Plaza'),
                                    const SizedBox(height: 8),
                                    _styledTextField(
                                      controller: _requDescripcionController,
                                      hintText: 'Descripción del requisito',
                                      fontSize: 15,
                                      validator: (value) {
                                        if (_currentSection == 2 && value != null && value.isEmpty) {
                                          return 'Ingrese la descripción';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    _styledTextField(
                                      controller: _requInformacionController,
                                      hintText: 'Información del requisito',
                                      fontSize: 15,
                                      validator: (value) {
                                        if (_currentSection == 2 && value != null && value.isEmpty) {
                                          return 'Ingrese la información';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _addRequisito,
                                        icon: const Icon(Icons.add),
                                        label: const Text('Agregar Requisito'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    if (_requisitos.isNotEmpty)
                                      Card(
                                        color: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _requisitos.length,
                                          itemBuilder: (context, index) {
                                            final req = _requisitos[index];
                                            return ListTile(
                                              title: Text(
                                                req['requ_Descripcion'] ?? '',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              subtitle: Text(req['requ_Informacion'] ?? ''),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => _removeRequisito(index),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (_requisitos.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Text(
                                          'Agrega al menos un requisito para la plaza.',
                                          style: TextStyle(color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _goToSection(1),
                                          icon: const Icon(Icons.arrow_back),
                                          label: const Text('Atrás'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accentColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: _cargando
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!.validate() && _requisitos.isNotEmpty) {
                                                    _publicarPlaza();
                                                  } else {
                                                    // Show toast with missing fields
                                                    String missing = '';
                                                    if (_selectedImage == null) missing += 'Imagen, ';
                                                    if (_tituloController.text.trim().isEmpty) missing += 'Título, ';
                                                    if (_informacionController.text.trim().isEmpty) missing += 'Información, ';
                                                    if (_direccionController.text.trim().isEmpty) missing += 'Dirección, ';
                                                    if (_selectedCargoId == null) missing += 'Cargo, ';
                                                    if (_selectedCategoriaId == null) missing += 'Categoría, ';
                                                    if (_selectedTipoContratoId == null) missing += 'Tipo de Contrato, ';
                                                    if (_requisitos.isEmpty) missing += 'Al menos un requisito, ';
                                                    if (missing.endsWith(', ')) missing = missing.substring(0, missing.length - 2);
                                                    _showToast('Faltan campos: $missing');
                                                  }
                                                },
                                          icon: const Icon(Icons.check),
                                          label: _cargando
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text('Publicar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_mensaje.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  _mensaje,
                                  style: TextStyle(
                                    color: _mensaje.contains('Bienvenido') || _mensaje.toLowerCase().contains('publicada')
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper for section titles
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF23272F),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );

  // Helper for styled text fields
  Widget _styledTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    double fontSize = 14,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.normal,
          ),
          fillColor: const Color(0xFFF5F5F7),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              color: Color(0xFFEE4D00),
              width: 1,
            ),
          ),
        ),
        validator: validator,
      );

  // Helper for dropdown decoration
  InputDecoration _dropdownDecoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
      );

  // Section stepper indicator
  Widget _sectionStepper(int section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18, top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle(0, section == 0, 'Datos'),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 38,
              height: 3,
              decoration: BoxDecoration(
                color: section > 0 ? const Color(0xFFEE4D00) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _stepCircle(1, section == 1, 'Dirección'),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 38,
              height: 3,
              decoration: BoxDecoration(
                color: section == 2 ? const Color(0xFFEE4D00) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _stepCircle(2, section == 2, 'Requisitos'),
        ],
      ),
    );
  }

  Widget _stepCircle(int idx, bool active, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: active ? const Color(0xFFEE4D00) : Colors.grey.shade300,
          child: Text(
            '${idx + 1}',
            style: TextStyle(
              color: active ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? const Color(0xFFEE4D00) : Colors.black54,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}