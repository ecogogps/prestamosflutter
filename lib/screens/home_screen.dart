import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _ubicacionA;
  String? _ubicacionB;
  final _descripcionController = TextEditingController();
  bool _isLoading = false;

  final List<String> _locations = ['punto a', 'punto b'];

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Funcionalidad no implementada. Se necesita un endpoint en el backend.'),
          backgroundColor: Colors.amber,
        ),
      );

      // TODO: Implementar la llamada al backend de Laravel para guardar la solicitud.
      // final success = await someApiService.createRequest(
      //   ubicacionA: _ubicacionA!,
      //   ubicacionB: _ubicacionB!,
      //   descripcion: _descripcionController.text,
      // );
      
      // if (success) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Solicitud creada con éxito'),
      //       backgroundColor: Colors.green,
      //     ),
      //   );
      //   _formKey.currentState!.reset();
      //   _descripcionController.clear();
      //   setState(() {
      //     _ubicacionA = null;
      //     _ubicacionB = null;
      //   });
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Error al crear la solicitud'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Solicitud'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _ubicacionA,
                  decoration:
                      const InputDecoration(labelText: 'Ubicación A'),
                  items: _locations.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _ubicacionA = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Por favor, seleccione una ubicación' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _ubicacionB,
                  decoration:
                      const InputDecoration(labelText: 'Ubicación B'),
                  items: _locations.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _ubicacionB = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Por favor, seleccione una ubicación' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Por favor, ingrese una descripción' : null,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitRequest,
                        child: const Text('Enviar Solicitud'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
