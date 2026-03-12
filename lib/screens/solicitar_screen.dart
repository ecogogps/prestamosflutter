import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

import '../core/app_colors.dart'; 
import 'custom_camera_screen.dart'; 

class SolicitarScreen extends StatefulWidget {
  const SolicitarScreen({super.key});

  @override
  State<SolicitarScreen> createState() => _SolicitarScreenState();
}

class _SolicitarScreenState extends State<SolicitarScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  // Controllers Seccion 1
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Controllers Seccion 3 (Referencias editables)
  final _ref1NameController = TextEditingController();
  final _ref1PhoneController = TextEditingController();
  final _ref2NameController = TextEditingController();
  final _ref2PhoneController = TextEditingController();

  // Seccion 1 - Perfil
  String _gender = 'Masculino';
  final _dobMask = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

  // Seccion 2 - Inicial
  String _housingType = 'Propia';
  String? _selectedProvince;
  String? _selectedCity;
  String _maritalStatus = 'Soltero/a';
  String _educationLevel = 'Secundaria';

  // Base de datos de los 32 Estados de México y principales ciudades
  final Map<String, List<String>> _mexicoData = {
    'Aguascalientes': ['Aguascalientes', 'Asientos', 'Calvillo', 'Jesús María', 'Rincón de Romos'],
    'Baja California': ['Ensenada', 'Mexicali', 'Playas de Rosarito', 'Tecate', 'Tijuana'],
    'Baja California Sur': ['Comondú', 'La Paz', 'Loreto', 'Los Cabos', 'Mulegé'],
    'Campeche': ['Campeche', 'Carmen', 'Champotón', 'Escárcega', 'Calkiní'],
    'Chiapas': ['Tuxtla Gutiérrez', 'San Cristóbal de las Casas', 'Tapachula', 'Palenque', 'Comitán'],
    'Chihuahua': ['Chihuahua', 'Ciudad Juárez', 'Cuauhtémoc', 'Delicias', 'Hidalgo del Parral'],
    'Ciudad de México': ['Álvaro Obregón', 'Azcapotzalco', 'Benito Juárez', 'Coyoacán', 'Cuauhtémoc', 'Gustavo A. Madero', 'Iztacalco', 'Iztapalapa', 'Miguel Hidalgo', 'Tlalpan', 'Venustiano Carranza', 'Xochimilco'],
    'Coahuila': ['Saltillo', 'Torreón', 'Monclova', 'Piedras Negras', 'Acuña'],
    'Colima': ['Colima', 'Manzanillo', 'Tecomán', 'Villa de Álvarez', 'Armería'],
    'Durango': ['Durango', 'Gómez Palacio', 'Lerdo', 'Pueblo Nuevo', 'Santiago Papasquiaro'],
    'Estado de México': ['Toluca', 'Ecatepec', 'Nezahualcóyotl', 'Naucalpan', 'Tlalnepantla', 'Chimalhuacán', 'Cuautitlán Izcalli', 'Atizapán', 'Ixtapaluca', 'Valle de Chalco'],
    'Guanajuato': ['León', 'Irapuato', 'Celaya', 'Salamanca', 'Guanajuato', 'Silao'],
    'Guerrero': ['Acapulco', 'Chilpancingo', 'Iguala', 'Zihuatanejo', 'Taxco'],
    'Hidalgo': ['Pachuca', 'Tulancingo', 'Tula de Allende', 'Mineral de la Reforma', 'Huejutla'],
    'Jalisco': ['Guadalajara', 'Zapopan', 'Tlaquepaque', 'Tlajomulco', 'Tonalá', 'Puerto Vallarta'],
    'Michoacán': ['Morelia', 'Uruapan', 'Zamora', 'Lázaro Cárdenas', 'Apatzingán'],
    'Morelos': ['Cuernavaca', 'Jiutepec', 'Cuautla', 'Temixco', 'Yautepec'],
    'Nayarit': ['Tepic', 'Bahía de Banderas', 'Xalisco', 'Compostela', 'Santiago Ixcuintla'],
    'Nuevo León': ['Monterrey', 'Apodaca', 'Guadalupe', 'San Nicolás', 'San Pedro Garza García', 'Santa Catarina', 'Escobedo'],
    'Oaxaca': ['Oaxaca de Juárez', 'San Juan Bautista Tuxtepec', 'Salina Cruz', 'Juchitán', 'Santa Cruz Xoxocotlán'],
    'Puebla': ['Puebla', 'Tehuacán', 'San Andrés Cholula', 'Atlixco', 'San Pedro Cholula', 'Teziutlán'],
    'Querétaro': ['Querétaro', 'San Juan del Río', 'Corregidora', 'El Marqués', 'Tequisquiapan'],
    'Quintana Roo': ['Cancún', 'Playa del Carmen', 'Chetumal', 'Cozumel', 'Tulum'],
    'San Luis Potosí': ['San Luis Potosí', 'Soledad', 'Ciudad Valles', 'Matehuala', 'Rioverde'],
    'Sinaloa': ['Culiacán', 'Mazatlán', 'Los Mochis', 'Guasave', 'Navolato'],
    'Sonora': ['Hermosillo', 'Ciudad Obregón', 'Nogales', 'San Luis Río Colorado', 'Navojoa'],
    'Tabasco': ['Villahermosa', 'Cárdenas', 'Comalcalco', 'Macuspana', 'Huimanguillo'],
    'Tamaulipas': ['Reynosa', 'Matamoros', 'Nuevo Laredo', 'Tampico', 'Ciudad Victoria', 'Ciudad Madero'],
    'Tlaxcala': ['Tlaxcala', 'Apizaco', 'Huamantla', 'Chiautempan', 'Zacatelco'],
    'Veracruz': ['Veracruz', 'Xalapa', 'Coatzacoalcos', 'Córdoba', 'Poza Rica', 'Boca del Río', 'Orizaba'],
    'Yucatán': ['Mérida', 'Kanasín', 'Valladolid', 'Tizimín', 'Progreso'],
    'Zacatecas': ['Zacatecas', 'Guadalupe', 'Fresnillo', 'Jerez', 'Río Grande']
  };

  // Bancos México
  final List<String> _mexicoBanks = [
    'BBVA México',
    'Banamex (Citibanamex)',
    'Santander México',
    'Banorte',
    'HSBC México',
    'Banco Azteca',
    'Scotiabank México',
    'Inbursa',
    'Banjercito',
    'BanCoppel',
    'Mercado Pago (MERCADO LIBRE)',
    'Nu México (Nubank)',
    'Albo',
    'Klar',
    'Stori',
    'Hey Banco'
  ];

  // Seccion 3 - Relaciones
  String _ref1Relation = 'Padre/Madre';
  String _ref2Relation = 'Hermano/a';

  // Seccion 4 - Files
  File? _facePhoto;
  File? _idFront;
  File? _idBack;

  // Seccion 5 - Prestamo
  double _amount = 5000;
  final int _paymentTerm = 7;
  final String _paymentMethod = 'Semanal';
  String? _selectedBank;

  Future<void> _pickContact(int refNum) async {
    if (await Permission.contacts.request().isGranted) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(contact.id);
        setState(() {
          if (refNum == 1) {
            _ref1NameController.text = fullContact?.displayName ?? '';
            _ref1PhoneController.text = fullContact?.phones.firstOrNull?.number ?? '';
          } else {
            _ref2NameController.text = fullContact?.displayName ?? '';
            _ref2PhoneController.text = fullContact?.phones.firstOrNull?.number ?? '';
          }
        });
      }
    } else {
      _showError('Se requiere permiso de contactos');
    }
  }

  Future<void> _pickFaceImage() async {
    if (await Permission.camera.request().isGranted) {
      final imagePath = await Navigator.push<String?>(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomCameraScreen(
            requiredLensDirection: CameraLensDirection.front, 
            isSquareGuide: true,
          ),
        ),
      );

      if (imagePath != null) {
        setState(() => _facePhoto = File(imagePath));
      }
    } else {
      _showError('Se requiere permiso de cámara para continuar');
    }
  }

  Future<void> _pickIdImage({required bool isFront}) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(isFront ? 'Identificación Frontal *' : 'Identificación Trasera *',
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Elegir de Galería',
                    style: TextStyle(color: AppColors.text)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      if (isFront) {
                        _idFront = File(pickedFile.path);
                      } else {
                        _idBack = File(pickedFile.path);
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Tomar con Cámara Trasera',
                    style: TextStyle(color: AppColors.text)),
                onTap: () async {
                  Navigator.pop(ctx);
                  if (await Permission.camera.request().isGranted) {
                    final imagePath = await Navigator.push<String?>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomCameraScreen(
                          requiredLensDirection: CameraLensDirection.back, 
                          isSquareGuide: false,
                        ),
                      ),
                    );

                    if (imagePath != null) {
                      setState(() {
                        if (isFront) {
                          _idFront = File(imagePath);
                        } else {
                          _idBack = File(imagePath);
                        }
                      });
                    }
                  } else {
                    _showError('Se requiere permiso de cámara');
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _uploadFile(File file, String folder) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final fileExt = file.path.split('.').last;
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '$folder/$fileName';

      await supabase.storage.from('loan-files').upload(path, file);
      return supabase.storage.from('loan-files').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error upload: $e');
      return null;
    }
  }

  Future<void> _submitRequest() async {
    if (_isLoading) return;

    // Validación de campos obligatorios
    if (_firstNameController.text.isEmpty || 
        _lastNameController.text.isEmpty || 
        _dobController.text.isEmpty || 
        _docNumberController.text.isEmpty || 
        _accountNumberController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _addressController.text.isEmpty ||
        _selectedProvince == null ||
        _selectedCity == null ||
        _selectedBank == null ||
        _ref1NameController.text.isEmpty || 
        _ref1PhoneController.text.isEmpty || 
        _ref2NameController.text.isEmpty || 
        _ref2PhoneController.text.isEmpty ||
        _facePhoto == null || 
        _idFront == null ||
        _idBack == null) {
      _showError('Todos los campos marcados con * son obligatorios');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final faceUrl = await _uploadFile(_facePhoto!, 'faces');
      final idFrontUrl = await _uploadFile(_idFront!, 'ids_front');
      final idBackUrl = await _uploadFile(_idBack!, 'ids_back');

      await supabase.from('loans').insert({
        'user_id': supabase.auth.currentUser!.id,
        'amount': _amount,
        'payment_term': _paymentTerm,
        'payment_method': _paymentMethod,
        'bank_name': _selectedBank,
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
        'ref1_name': _ref1NameController.text,
        'ref1_phone': _ref1PhoneController.text,
        'ref2_relation': _ref2Relation,
        'ref2_name': _ref2NameController.text,
        'ref2_phone': _ref2PhoneController.text,
        'face_photo_url': faceUrl,
        'id_front_url': idFrontUrl,
        'id_back_url': idBackUrl,
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

  void _showSelectionSheet(
      String title, List<String> items, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(title,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final e = items[index];
                    return ListTile(
                      title: Text(e, style: const TextStyle(color: AppColors.text)),
                      onTap: () {
                        onSelect(e);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableRow(
      String label, String? value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(value ?? 'Seleccionar',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.text, fontSize: 16)),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      bool onlyDigits = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.text),
            inputFormatters: [
              if (onlyDigits) FilteringTextInputFormatter.digitsOnly,
              ...?inputFormatters,
            ],
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBox({
    required String label,
    required File? file,
    required VoidCallback onTap,
    required IconData icon,
    required double aspectRatio, 
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: file != null ? AppColors.primary : Colors.white12),
              ),
              child: file != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: aspectRatio,
                        child: Image.file(file, fit: BoxFit.cover),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(icon, size: 48, color: Colors.white30),
                          const SizedBox(height: 12),
                          const Text('Toca para capturar',
                              style: TextStyle(color: AppColors.text)),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP WIDGETS ---

  Widget _buildStepProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_firstNameController, 'Nombres *'),
        _buildTextField(_lastNameController, 'Apellidos *'),
        _buildSelectableRow('Género *', _gender, () {
          _showSelectionSheet('Género', ['Masculino', 'Femenino'],
              (val) => setState(() => _gender = val));
        }),
        _buildTextField(_dobController, 'Fecha Nacimiento (DD/MM/AAAA) *',
            inputFormatters: [_dobMask],
            keyboardType: TextInputType.datetime),
        _buildTextField(_docNumberController, 'Número Documento *'), // Alfanumérico
        _buildSelectableRow('Banco *', _selectedBank, () {
          _showSelectionSheet('Seleccionar Banco', _mexicoBanks,
              (val) => setState(() => _selectedBank = val));
        }),
        _buildTextField(_accountNumberController, 'Número de Cuenta *',
            onlyDigits: true, keyboardType: TextInputType.number),
        _buildTextField(_emailController, 'Correo Electrónico *',
            keyboardType: TextInputType.emailAddress),
        _buildTextField(_addressController, 'Dirección Domicilio *'),
      ],
    );
  }

  Widget _buildStepInitial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectableRow('Tipo de Vivienda *', _housingType, () {
          _showSelectionSheet('Tipo de Vivienda', ['Propia', 'Renta', 'Otros'],
              (val) => setState(() => _housingType = val));
        }),
        _buildSelectableRow('Estado *', _selectedProvince, () {
          _showSelectionSheet('Estado', _mexicoData.keys.toList(), (val) {
            setState(() {
              _selectedProvince = val;
              _selectedCity = null; 
            });
          });
        }),
        _buildSelectableRow('Ciudad *', _selectedCity, () {
          if (_selectedProvince == null) {
            _showError('Por favor seleccione un estado primero');
            return;
          }
          _showSelectionSheet('Ciudad', _mexicoData[_selectedProvince]!,
              (val) => setState(() => _selectedCity = val));
        }),
        _buildSelectableRow('Estado civil *', _maritalStatus, () {
          _showSelectionSheet('Estado civil',
              ['Soltero/a', 'Casado/a', 'Divorciado/a', 'Viudo/a'],
              (val) => setState(() => _maritalStatus = val));
        }),
        _buildSelectableRow('Máximo nivel estudios *', _educationLevel, () {
          _showSelectionSheet(
              'Nivel estudios',
              ['Primaria', 'Secundaria', 'Preparatoria', 'Universidad', 'Postgrado'],
              (val) => setState(() => _educationLevel = val));
        }),
      ],
    );
  }

  Widget _buildStepReferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contacto 1 *', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSelectableRow('Relación Contacto 1 *', _ref1Relation, () {
          _showSelectionSheet(
              'Relación 1',
              ['Padre/Madre', 'Hermano/a', 'Compañero Trabajo', 'Amigo/a'],
              (val) => setState(() => _ref1Relation = val));
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.contact_phone, color: AppColors.primary),
              label: const Text('Importar de agenda', style: TextStyle(color: AppColors.primary)),
              onPressed: () => _pickContact(1),
            )
          ],
        ),
        _buildTextField(_ref1NameController, 'Nombre Completo (Contacto 1) *'),
        _buildTextField(_ref1PhoneController, 'Teléfono (Contacto 1) *', onlyDigits: true, keyboardType: TextInputType.phone),
        
        const Divider(height: 40, color: Colors.white12),

        const Text('Contacto 2 *', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSelectableRow('Relación Contacto 2 *', _ref2Relation, () {
          _showSelectionSheet(
              'Relación 2',
              ['Padre/Madre', 'Hermano/a', 'Compañero Trabajo', 'Amigo/a'],
              (val) => setState(() => _ref2Relation = val));
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.contact_phone, color: AppColors.primary),
              label: const Text('Importar de agenda', style: TextStyle(color: AppColors.primary)),
              onPressed: () => _pickContact(2),
            )
          ],
        ),
        _buildTextField(_ref2NameController, 'Nombre Completo (Contacto 2) *'),
        _buildTextField(_ref2PhoneController, 'Teléfono (Contacto 2) *', onlyDigits: true, keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _buildStepFiles() {
    return Column(
      children: [
        _buildPhotoBox(
            label: 'Tomar foto de rostro (Cámara Frontal) *', 
            file: _facePhoto, 
            onTap: _pickFaceImage, 
            icon: Icons.face,
            aspectRatio: 1.0, 
        ),
        _buildPhotoBox(
            label: 'Adjuntar frontal identificación (Trasera/Galería) *', 
            file: _idFront, 
            onTap: () => _pickIdImage(isFront: true), 
            icon: Icons.credit_card,
            aspectRatio: 1.586, 
        ),
        _buildPhotoBox(
            label: 'Adjuntar reverso identificación (Trasera/Galería) *', 
            file: _idBack, 
            onTap: () => _pickIdImage(isFront: false), 
            icon: Icons.credit_card_outlined,
            aspectRatio: 1.586, 
        ),
      ],
    );
  }

  Widget _buildStepLoan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Cuánto dinero necesitas? *',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 20),
        Center(
          child: Text('\$${_amount.toInt()} MXN',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
        ),
        Slider(
          value: _amount,
          min: 500,
          max: 50500,
          divisions: 100,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
          label: '\$${_amount.toInt()}',
          onChanged: (val) =>
              setState(() => _amount = (val / 500).round() * 500.0),
        ),
        const SizedBox(height: 20),
        
        // Campo Plazo fijo en 7 días
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Plazo de Pago (Días) *', style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text('$_paymentTerm días', style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        // Forma de Pago fija en Semanal
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Forma de Pago *', style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(_paymentMethod, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getCurrentStepWidget() {
    switch (_currentStep) {
      case 0: return _buildStepProfile();
      case 1: return _buildStepInitial();
      case 2: return _buildStepReferences();
      case 3: return _buildStepFiles();
      case 4: return _buildStepLoan();
      default: return const SizedBox.shrink();
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Perfil';
      case 1: return 'Datos Iniciales';
      case 2: return 'Referencias';
      case 3: return 'Archivos';
      case 4: return 'Préstamo';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == 4;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_getStepTitle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              context.pop(); 
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 5,
                    backgroundColor: Colors.white12,
                    color: AppColors.primary,
                    minHeight: 4,
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                      child: _getCurrentStepWidget(),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (isLastStep) {
                                _submitRequest();
                              } else {
                                setState(() => _currentStep += 1);
                              }
                            },
                            child: Text(
                              isLastStep ? 'Enviar' : 'Próximo paso',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.security, size: 14, color: Colors.white70),
                            SizedBox(width: 6),
                            Text(
                              'La plataforma protege la seguridad de sus datos',
                              style:
                                  TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}