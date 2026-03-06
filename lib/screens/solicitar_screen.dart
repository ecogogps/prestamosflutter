import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final _supabase = Supabase.instance.client;

  // Mask for DOB
  final _dobMask = MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

  // Step 1: Perfil
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _gender = 'Masculino';
  final _dobController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Step 2: Inicial
  String _housingType = 'Propia';
  String _selectedState = 'Ciudad de México';
  String _maritalStatus = 'Soltero/a';
  String _educationLevel = 'Licenciatura';

  // Step 3: Referencias
  String _ref1Relation = 'Padre/Madre';
  String _ref1Name = '';
  String _ref1Phone = '';
  String _ref2Relation = 'Hermano/a';
  String _ref2Name = '';
  String _ref2Phone = '';

  // Step 4: Files
  File? _facePhoto;
  File? _idFrontPhoto;

  // Step 5: Préstamo
  double _amount = 5000;
  int _term = 7;
  String _paymentMethod = 'Pago semanal';

  final List<String> _mexicoStates = [
    'Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche', 'Chiapas', 
    'Chihuahua', 'Ciudad de México', 'Coahuila', 'Colima', 'Durango', 'Estado de México', 
    'Guanajuato', 'Guerrero', 'Hidalgo', 'Jalisco', 'Michoacán', 'Morelos', 'Nayarit', 
    'Nuevo León', 'Oaxaca', 'Puebla', 'Querétaro', 'Quintana Roo', 'San Luis Potosí', 
    'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 'Veracruz', 'Yucatán', 'Zacatecas'
  ];

  Future<void> _pickContact(int refNum) async {
    if (await Permission.contacts.request().isGranted) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(contact.id);
        if (fullContact != null && fullContact.phones.isNotEmpty) {
          setState(() {
            if (refNum == 1) {
              _ref1Name = fullContact.displayName;
              _ref1Phone = fullContact.phones.first.number;
            } else {
              _ref2Name = fullContact.displayName;
              _ref2Phone = fullContact.phones.first.number;
            }
          });
        }
      }
    }
  }

  Future<void> _takePhoto(bool isFace) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: isFace ? ImageSource.camera : ImageSource.gallery,
      preferredCameraDevice: CameraDevice.front,
    );

    if (image != null) {
      setState(() {
        if (isFace) {
          _facePhoto = File(image.path);
        } else {
          _idFrontPhoto = File(image.path);
        }
      });
    }
  }

  Future<String?> _uploadFile(File file, String name) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileExt = file.path.split('.').last;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_$name.$fileExt';
      final path = 'loan-files/$fileName';

      await _supabase.storage.from('loan-files').upload(path, file);
      return _supabase.storage.from('loan-files').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _submitRequest() async {
    if (_facePhoto == null || _idFrontPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor adjunta las fotos requeridas')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final faceUrl = await _uploadFile(_facePhoto!, 'face');
      final idUrl = await _uploadFile(_idFrontPhoto!, 'id_front');

      await _supabase.from('loans').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'amount': _amount,
        'payment_term': _term,
        'payment_method': _paymentMethod,
        'first_name': _nameController.text,
        'last_name': _lastNameController.text,
        'gender': _gender,
        'dob': _dobController.text,
        'doc_number': _docNumberController.text,
        'account_number': _accountNumberController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'housing_type': _housingType,
        'province': _selectedState,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud enviada con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Solicitar Préstamo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 4) {
              setState(() => _currentStep += 1);
            } else {
              _submitRequest();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_currentStep == 4 ? 'Solicitar ahora' : 'Siguiente'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                        ),
                        child: const Text('Atrás'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Perfil', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 0,
              content: Column(
                children: [
                  _buildTextField(_nameController, 'Nombres'),
                  _buildTextField(_lastNameController, 'Apellidos'),
                  _buildDropdown('Género', _gender, ['Masculino', 'Femenino'], (val) => setState(() => _gender = val!)),
                  _buildTextField(_dobController, 'Fecha de Nacimiento', inputFormatters: [_dobMask], hint: 'DD/MM/AAAA'),
                  _buildTextField(_docNumberController, 'Número de Documento', isNumber: true),
                  _buildTextField(_accountNumberController, 'Número de Cuenta', isNumber: true),
                  _buildTextField(_emailController, 'Correo electrónico'),
                  _buildTextField(_addressController, 'Dirección Domicilio'),
                ],
              ),
            ),
            Step(
              title: const Text('Información Inicial', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 1,
              content: Column(
                children: [
                  _buildDropdown('Tipo de Vivienda', _housingType, ['Propia', 'Renta', 'Otros'], (val) => setState(() => _housingType = val!)),
                  _buildDropdown('Estado', _selectedState, _mexicoStates, (val) => setState(() => _selectedState = val!)),
                  _buildDropdown('Estado Civil', _maritalStatus, ['Soltero/a', 'Casado/a', 'Divorciado/a', 'Viudo/a', 'Unión Libre'], (val) => setState(() => _maritalStatus = val!)),
                  _buildDropdown('Nivel de Estudios', _educationLevel, ['Primaria', 'Secundaria', 'Preparatoria', 'Licenciatura', 'Postgrado'], (val) => setState(() => _educationLevel = val!)),
                ],
              ),
            ),
            Step(
              title: const Text('Referencias', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  _buildReferenceSection(1),
                  const Divider(color: Colors.white10, height: 32),
                  _buildReferenceSection(2),
                ],
              ),
            ),
            Step(
              title: const Text('Documentación', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 3,
              content: Column(
                children: [
                  _buildFilePicker('Foto de tu cara (Cámara)', _facePhoto, () => _takePhoto(true)),
                  const SizedBox(height: 16),
                  _buildFilePicker('Frente de tu Cédula (Galería)', _idFrontPhoto, () => _takePhoto(false)),
                ],
              ),
            ),
            Step(
              title: const Text('Detalles del Préstamo', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 4,
              content: Column(
                children: [
                  Text(
                    'Monto: \$${_amount.toInt()} MXN',
                    style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _amount,
                    min: 500,
                    max: 50000,
                    divisions: 99,
                    onChanged: (val) => setState(() => _amount = val),
                  ),
                  _buildDropdown('Plazo (Días)', _term.toString(), ['7', '15', '30'], (val) => setState(() => _term = int.parse(val!))),
                  _buildDropdown('Forma de Pago', _paymentMethod, ['Diario', 'Pago semanal', 'Quincenal', 'Mensual'], (val) => setState(() => _paymentMethod = val!)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, List<TextInputFormatter>? inputFormatters, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildReferenceSection(int num) {
    final name = num == 1 ? _ref1Name : _ref2Name;
    final phone = num == 1 ? _ref1Phone : _ref2Phone;
    final relation = num == 1 ? _ref1Relation : _ref2Relation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Referencia $num', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildDropdown('Relación', relation, ['Padre/Madre', 'Hermano/a', 'Cónyuge', 'Compañero de trabajo', 'Amigo/a'], (val) {
          setState(() {
            if (num == 1) _ref1Relation = val!; else _ref2Relation = val!;
          });
        }),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(name.isEmpty ? 'Seleccionar contacto' : name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(phone.isEmpty ? 'Toca para elegir de tu agenda' : phone, style: const TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.contact_phone, color: AppColors.primary),
          onTap: () => _pickContact(num),
        ),
      ],
    );
  }

  Widget _buildFilePicker(String label, File? file, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: file == null ? Colors.white24 : AppColors.primary),
        ),
        child: Column(
          children: [
            Icon(file == null ? Icons.camera_alt : Icons.check_circle, color: file == null ? Colors.white54 : AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white70)),
            if (file != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(file, height: 100, width: double.infinity, fit: BoxFit.cover),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
