import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/app_colors.dart';

class SolicitarScreen extends StatefulWidget {
  const SolicitarScreen({super.key});

  @override
  State<SolicitarScreen> createState() => _SolicitarScreenState();
}

class _SolicitarScreenState extends State<SolicitarScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Mapeo de Estados y Ciudades de México
  final Map<String, List<String>> _mexicoData = {
    'Ciudad de México': ['Cuauhtémoc', 'Iztapalapa', 'Benito Juárez', 'Coyoacán', 'Miguel Hidalgo'],
    'Jalisco': ['Guadalajara', 'Zapopan', 'Tlaquepaque', 'Tlajomulco', 'Puerto Vallarta'],
    'Nuevo León': ['Monterrey', 'San Pedro Garza García', 'Guadalupe', 'Apodaca', 'San Nicolás'],
    'Estado de México': ['Toluca', 'Ecatepec', 'Naucalpan', 'Tlalnepantla', 'Nezahualcóyotl'],
    'Puebla': ['Puebla de Zaragoza', 'Tehuacán', 'San Andrés Cholula', 'Atlixco'],
    'Yucatán': ['Mérida', 'Kanasín', 'Valladolid', 'Tizimín'],
  };

  // Controladores de Texto
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _ref1NameController = TextEditingController();
  final _ref1PhoneController = TextEditingController();
  final _ref2NameController = TextEditingController();
  final _ref2PhoneController = TextEditingController();

  // Valores Seleccionados
  String? _selectedGender;
  String? _selectedHousing;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedMaritalStatus;
  String? _selectedEducation;
  String? _ref1Relation;
  String? _ref2Relation;
  
  // Préstamo
  double _monto = 5000;
  int _plazo = 7;
  String _formaPago = 'Semanal';

  // Archivos
  File? _facePhoto;
  File? _idFrontPhoto;

  final _dobFormatter = MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  final _dobController = TextEditingController();

  Future<void> _pickContact(int refNumber) async {
    final permission = await Permission.contacts.request();
    if (permission.isGranted) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        setState(() {
          if (refNumber == 1) {
            _ref1NameController.text = contact.displayName;
            _ref1PhoneController.text = contact.phones.first.number.replaceAll(RegExp(r'[^0-9]'), '');
          } else {
            _ref2NameController.text = contact.displayName;
            _ref2PhoneController.text = contact.phones.first.number.replaceAll(RegExp(r'[^0-9]'), '');
          }
        });
      }
    } else {
      _showError('Permiso de contactos denegado');
    }
  }

  Future<void> _takePhoto(bool isFace) async {
    final permission = await Permission.camera.request();
    if (permission.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: isFace ? CameraDevice.front : CameraDevice.rear,
      );

      if (pickedFile != null) {
        setState(() {
          if (isFace) _facePhoto = File(pickedFile.path);
          else _idFrontPhoto = File(pickedFile.path);
        });
      }
    } else {
      _showError('Permiso de cámara denegado');
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _idFrontPhoto = File(pickedFile.path);
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<String?> _uploadFile(File file, String folder) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$folder/$fileName';

      await supabase.storage.from('loan-files').upload(path, file);
      return supabase.storage.from('loan-files').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error upload: $e');
      return null;
    }
  }

  Future<void> _submitRequest() async {
    if (_facePhoto == null || _idFrontPhoto == null) {
      _showError('Por favor adjunta las fotos requeridas');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      final faceUrl = await _uploadFile(_facePhoto!, 'faces');
      final idUrl = await _uploadFile(_idFrontPhoto!, 'ids');

      await supabase.from('loans').insert({
        'user_id': userId,
        'amount': _monto,
        'payment_term': _plazo,
        'payment_method': _formaPago,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'gender': _selectedGender,
        'dob': _dobController.text,
        'doc_number': _docNumberController.text,
        'account_number': _accountNumberController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'housing_type': _selectedHousing,
        'province': _selectedProvince,
        'city': _selectedCity,
        'marital_status': _selectedMaritalStatus,
        'education_level': _selectedEducation,
        'ref1_relation': _ref1Relation,
        'ref1_name': _ref1NameController.text,
        'ref1_phone': _ref1PhoneController.text,
        'ref2_relation': _ref2Relation,
        'ref2_name': _ref2NameController.text,
        'ref2_phone': _ref2PhoneController.text,
        'face_photo_url': faceUrl,
        'id_front_url': idUrl,
        'status': 'pending',
      });

      if (mounted) {
        context.go('/prestamos');
      }
    } catch (e) {
      _showError('Error al procesar la solicitud: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Solicitar Préstamo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: AppColors.primary),
            ),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 4) {
                  setState(() => _currentStep += 1);
                } else {
                  _submitRequest();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep -= 1);
              },
              steps: [
                Step(
                  isActive: _currentStep >= 0,
                  title: const Text(''),
                  label: const Text('Perfil', style: TextStyle(fontSize: 10, color: Colors.white)),
                  content: _buildStepPerfil(),
                ),
                Step(
                  isActive: _currentStep >= 1,
                  title: const Text(''),
                  label: const Text('Ubicación', style: TextStyle(fontSize: 10, color: Colors.white)),
                  content: _buildStepInicial(),
                ),
                Step(
                  isActive: _currentStep >= 2,
                  title: const Text(''),
                  label: const Text('Referencias', style: TextStyle(fontSize: 10, color: Colors.white)),
                  content: _buildStepReferencias(),
                ),
                Step(
                  isActive: _currentStep >= 3,
                  title: const Text(''),
                  label: const Text('Archivos', style: TextStyle(fontSize: 10, color: Colors.white)),
                  content: _buildStepFiles(),
                ),
                Step(
                  isActive: _currentStep >= 4,
                  title: const Text(''),
                  label: const Text('Préstamo', style: TextStyle(fontSize: 10, color: Colors.white)),
                  content: _buildStepPrestamo(),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStepPerfil() {
    return Column(
      children: [
        _buildTextField('Nombres', _firstNameController),
        _buildTextField('Apellidos', _lastNameController),
        _buildDropdown('Género', ['Masculino', 'Femenino'], _selectedGender, (val) => setState(() => _selectedGender = val)),
        _buildTextField('Fecha de nacimiento (DD/MM/AAAA)', _dobController, formatter: _dobFormatter),
        _buildTextField('Número de documento', _docNumberController, isNumber: true),
        _buildTextField('Número de cuenta', _accountNumberController, isNumber: true),
        _buildTextField('Correo electrónico', _emailController, keyboardType: TextInputType.emailAddress),
        _buildTextField('Dirección Domicilio', _addressController),
      ],
    );
  }

  Widget _buildStepInicial() {
    return Column(
      children: [
        _buildDropdown('Tipo de Vivienda', ['Otros', 'Renta', 'Propia'], _selectedHousing, (val) => setState(() => _selectedHousing = val)),
        _buildDropdown('Estado', _mexicoData.keys.toList(), _selectedProvince, (val) {
          setState(() {
            _selectedProvince = val;
            _selectedCity = null; // Reset ciudad al cambiar estado
          });
        }),
        if (_selectedProvince != null)
          _buildDropdown('Ciudad', _mexicoData[_selectedProvince]!, _selectedCity, (val) => setState(() => _selectedCity = val)),
        _buildDropdown('Estado Civil', ['Soltero/a', 'Casado/a', 'Divorciado/a', 'Viudo/a', 'Unión Libre'], _selectedMaritalStatus, (val) => setState(() => _selectedMaritalStatus = val)),
        _buildDropdown('Nivel de Estudios', ['Primaria', 'Secundaria', 'Preparatoria', 'Licenciatura', 'Postgrado'], _selectedEducation, (val) => setState(() => _selectedEducation = val)),
      ],
    );
  }

  Widget _buildStepReferencias() {
    final relations = ['Padre/Madre', 'Hermano/a', 'Compañero Trabajo', 'Amigo/a', 'Cónyuge', 'Otro'];
    return Column(
      children: [
        const Text('Referencia 1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        _buildDropdown('Relación', relations, _ref1Relation, (val) => setState(() => _ref1Relation = val)),
        _buildContactField(_ref1NameController, _ref1PhoneController, () => _pickContact(1)),
        const Divider(color: Colors.white24, height: 40),
        const Text('Referencia 2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        _buildDropdown('Relación', relations, _ref2Relation, (val) => setState(() => _ref2Relation = val)),
        _buildContactField(_ref2NameController, _ref2PhoneController, () => _pickContact(2)),
      ],
    );
  }

  Widget _buildStepFiles() {
    return Column(
      children: [
        _buildFileCard('Foto de rostro', Icons.face, _facePhoto, () => _takePhoto(true)),
        const SizedBox(height: 20),
        _buildFileCard('Foto frontal de identificación', Icons.badge, _idFrontPhoto, () => _takePhoto(false), onGallery: _pickFromGallery),
      ],
    );
  }

  Widget _buildStepPrestamo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Monto del préstamo', style: TextStyle(color: Colors.white, fontSize: 16)),
        Slider(
          value: _monto,
          min: 500,
          max: 50000,
          divisions: 99,
          label: '\$${_monto.toInt()}',
          onChanged: (val) => setState(() => _monto = val),
        ),
        Center(child: Text('\$${_monto.toInt()} MXN', style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold))),
        const SizedBox(height: 20),
        const Text('Plazo de pago (días)', style: TextStyle(color: Colors.white)),
        _buildDropdown('Selecciona el plazo', ['7', '15', '30'], _plazo.toString(), (val) => setState(() => _plazo = int.parse(val!))),
        const SizedBox(height: 20),
        const Text('Forma de pago', style: TextStyle(color: Colors.white)),
        _buildDropdown('Selecciona la forma', ['Diario', 'Semanal', 'Quincenal'], _formaPago, (val) => setState(() => _formaPago = val!)),
      ],
    );
  }

  // Widgets Auxiliares
  Widget _buildTextField(String label, TextEditingController controller, {TextInputFormatter? formatter, bool isNumber = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        inputFormatters: [
          if (formatter != null) formatter,
          if (isNumber) FilteringTextInputFormatter.digitsOnly,
        ],
        keyboardType: isNumber ? TextInputType.number : keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppColors.background,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildContactField(TextEditingController name, TextEditingController phone, VoidCallback onPick) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('Nombre', name)),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.contact_phone, color: AppColors.primary),
              onPressed: onPick,
            ),
          ],
        ),
        _buildTextField('Teléfono', phone, isNumber: true),
      ],
    );
  }

  Widget _buildFileCard(String label, IconData icon, File? file, VoidCallback onCamera, {VoidCallback? onGallery}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (file != null)
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(file, height: 150, width: double.infinity, fit: BoxFit.cover))
          else
            Icon(icon, size: 60, color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
              ),
              if (onGallery != null) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
