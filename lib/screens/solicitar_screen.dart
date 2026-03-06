import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
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
  final supabase = Supabase.instance.client;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Seccion 1 - Perfil
  String _gender = 'Masculino';
  final _dobMask = MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

  // Seccion 2 - Inicial
  String _housingType = 'Propia';
  String? _selectedProvince;
  String? _selectedCity;
  String _maritalStatus = 'Soltero/a';
  String _educationLevel = 'Secundaria';

  final Map<String, List<String>> _mexicoData = {
    'CDMX': ['Benito Juárez', 'Coyoacán', 'Cuauhtémoc', 'Iztapalapa'],
    'Jalisco': ['Guadalajara', 'Zapopan', 'Tlaquepaque', 'Tlajomulco'],
    'Nuevo León': ['Monterrey', 'San Pedro', 'Guadalupe', 'Apodaca'],
    'Estado de México': ['Toluca', 'Naucalpan', 'Ecatepec', 'Tlalnepantla'],
    'Puebla': ['Puebla City', 'Cholula', 'Atlixco'],
  };

  // Seccion 3 - Referencias
  String _ref1Relation = 'Padre/Madre';
  String _ref1Name = '';
  String _ref1Phone = '';
  String _ref2Relation = 'Hermano/a';
  String _ref2Name = '';
  String _ref2Phone = '';

  // Seccion 4 - Files
  File? _facePhoto;
  File? _idFront;

  // Seccion 5 - Prestamo
  double _amount = 5000;
  int _paymentTerm = 7;
  String _paymentMethod = 'Semanal';

  Future<void> _pickContact(int refNum) async {
    if (await Permission.contacts.request().isGranted) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(contact.id);
        setState(() {
          if (refNum == 1) {
            _ref1Name = fullContact?.displayName ?? '';
            _ref1Phone = fullContact?.phones.firstOrNull?.number ?? '';
          } else {
            _ref2Name = fullContact?.displayName ?? '';
            _ref2Phone = fullContact?.phones.firstOrNull?.number ?? '';
          }
        });
      }
    } else {
      _showError('Se requiere permiso de contactos');
    }
  }

  Future<void> _pickImage(bool isFace) async {
    final picker = ImagePicker();
    if (isFace) {
      if (await Permission.camera.request().isGranted) {
        final pickedFile = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
        if (pickedFile != null) setState(() => _facePhoto = File(pickedFile.path));
      }
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) setState(() => _idFront = File(pickedFile.path));
    }
  }

  Future<String?> _uploadFile(File file, String folder) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final fileExt = file.path.split('.').last;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '$folder/$fileName';

      await supabase.storage.from('loan-files').upload(path, file);
      return supabase.storage.from('loan-files').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error upload: $e');
      return null;
    }
  }

  Future<void> _submitRequest() async {
    if (_facePhoto == null || _idFront == null) {
      _showError('Debe adjuntar las fotos requeridas');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final faceUrl = await _uploadFile(_facePhoto!, 'faces');
      final idUrl = await _uploadFile(_idFront!, 'ids');

      await supabase.from('loans').insert({
        'user_id': supabase.auth.currentUser!.id,
        'amount': _amount,
        'payment_term': _paymentTerm,
        'payment_method': _paymentMethod,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'gender': _gender,
        'dob': _dobController.text,
        'doc_number': _docNumberController.text,
        'account_number': _accountNumberController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'housing_type': _housingType,
        'province': _selectedProvince,
        'city': _selectedCity,
        'marital_status': _maritalStatus,
        'education_level': _educationLevel,
        'ref1_relation': _ref1Relation,
        'ref1_name': _ref1Name,
        'ref1_phone': _ref1Phone,
        'ref2_relation': _ref2Relation,
        'ref2_name': _ref2Name,
        'ref2_phone': _ref2Phone,
        'face_photo_url': faceUrl,
        'id_front_url': idUrl,
        'status': 'pending',
      });

      if (mounted) {
        context.go('/prestamos');
      }
    } catch (e) {
      _showError('Error al enviar la solicitud: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Solicitud de Préstamo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: AppColors.primary),
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
                _buildStepProfile(),
                _buildStepInitial(),
                _buildStepReferences(),
                _buildStepFiles(),
                _buildStepLoan(),
              ],
            ),
          ),
    );
  }

  Step _buildStepProfile() {
    return Step(
      title: const Text('Perfil', style: TextStyle(fontSize: 10)),
      isActive: _currentStep >= 0,
      content: Column(
        children: [
          _buildTextField(_firstNameController, 'Nombres'),
          _buildTextField(_lastNameController, 'Apellidos'),
          _buildDropdown('Género', _gender, ['Masculino', 'Femenino'], (val) => setState(() => _gender = val!)),
          _buildTextField(_dobController, 'Fecha Nacimiento (DD/MM/AAAA)', inputFormatters: [_dobMask]),
          _buildTextField(_docNumberController, 'Número Documento', keyboardType: TextInputType.number),
          _buildTextField(_accountNumberController, 'Número de Cuenta', keyboardType: TextInputType.number),
          _buildTextField(_emailController, 'Correo Electrónico', keyboardType: TextInputType.emailAddress),
          _buildTextField(_addressController, 'Dirección Domicilio'),
        ],
      ),
    );
  }

  Step _buildStepInitial() {
    return Step(
      title: const Text('Inicial', style: TextStyle(fontSize: 10)),
      isActive: _currentStep >= 1,
      content: Column(
        children: [
          _buildDropdown('Tipo de Vivienda', _housingType, ['Propia', 'Renta', 'Otros'], (val) => setState(() => _housingType = val!)),
          _buildDropdown('Estado', _selectedProvince, _mexicoData.keys.toList(), (val) {
            setState(() {
              _selectedProvince = val;
              _selectedCity = null;
            });
          }),
          _buildDropdown('Ciudad', _selectedCity, _selectedProvince != null ? _mexicoData[_selectedProvince]! : [], (val) => setState(() => _selectedCity = val)),
          _buildDropdown('Estado Civil', _maritalStatus, ['Soltero/a', 'Casado/a', 'Divorciado/a', 'Viudo/a'], (val) => setState(() => _maritalStatus = val!)),
          _buildDropdown('Nivel Estudios', _educationLevel, ['Primaria', 'Secundaria', 'Preparatoria', 'Universidad', 'Postgrado'], (val) => setState(() => _educationLevel = val!)),
        ],
      ),
    );
  }

  Step _buildStepReferences() {
    return Step(
      title: const Text('Referencias', style: TextStyle(fontSize: 10)),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          _buildDropdown('Relación 1', _ref1Relation, ['Padre/Madre', 'Hermano/a', 'Compañero Trabajo', 'Amigo/a'], (val) => setState(() => _ref1Relation = val!)),
          _buildContactTile(1, _ref1Name, _ref1Phone),
          const Divider(height: 32),
          _buildDropdown('Relación 2', _ref2Relation, ['Padre/Madre', 'Hermano/a', 'Compañero Trabajo', 'Amigo/a'], (val) => setState(() => _ref2Relation = val!)),
          _buildContactTile(2, _ref2Name, _ref2Phone),
        ],
      ),
    );
  }

  Step _buildStepFiles() {
    return Step(
      title: const Text('Archivos', style: TextStyle(fontSize: 10)),
      isActive: _currentStep >= 3,
      content: Column(
        children: [
          _buildFilePicker('Tomar foto de rostro', _facePhoto, () => _pickImage(true), Icons.face),
          const SizedBox(height: 20),
          _buildFilePicker('Adjuntar frontal cédula', _idFront, () => _pickImage(false), Icons.credit_card),
        ],
      ),
    );
  }

  Step _buildStepLoan() {
    return Step(
      title: const Text('Préstamo', style: TextStyle(fontSize: 10)),
      isActive: _currentStep >= 4,
      content: Column(
        children: [
          const Text('¿Cuánto dinero necesitas?', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 20),
          Text('\$${_amount.toInt()} MXN', style: const TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold)),
          Slider(
            value: _amount,
            min: 500,
            max: 50500,
            divisions: 100,
            label: '\$${_amount.toInt()}',
            onChanged: (val) => setState(() => _amount = (val / 500).round() * 500.0),
          ),
          _buildDropdown('Plazo de Pago', _paymentTerm.toString(), ['7', '15', '30'], (val) => setState(() => _paymentTerm = int.parse(val!))),
          _buildDropdown('Forma de Pago', _paymentMethod, ['Diario', 'Semanal', 'Quincenal', 'Mensual'], (val) => setState(() => _paymentMethod = val!)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: [
          if (keyboardType == TextInputType.number) FilteringTextInputFormatter.digitsOnly,
          ...?inputFormatters,
        ],
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildContactTile(int refNum, String name, String phone) {
    return ListTile(
      title: Text(name.isEmpty ? 'Seleccionar Contacto' : name),
      subtitle: Text(phone.isEmpty ? 'Haz clic para abrir agenda' : phone),
      leading: const Icon(Icons.person_add, color: AppColors.primary),
      onTap: () => _pickContact(refNum),
      tileColor: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildFilePicker(String label, File? file, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: file != null ? AppColors.primary : Colors.white12),
        ),
        child: Column(
          children: [
            Icon(file != null ? Icons.check_circle : icon, size: 40, color: file != null ? AppColors.primary : Colors.white30),
            const SizedBox(height: 8),
            Text(file != null ? '¡Archivo listo!' : label),
          ],
        ),
      ),
    );
  }
}
