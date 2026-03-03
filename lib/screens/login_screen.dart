import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../core/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Image.network(
                  'https://i.postimg.cc/tTDNDSfZ/MONEYBIC-SIN-FONDO.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance_wallet, size: 80, color: AppColors.primary),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Bienvenido a MoneyBic',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingresa tu celular para continuar',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      child: Text('+52 ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    hintText: 'Número de celular (10 dígitos)',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: const TextStyle(color: AppColors.error),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa tu número';
                    if (value.length != 10) return 'Deben ser 10 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await authProvider.loginWithPhone(_phoneController.text);
                                if (mounted) context.push('/otp');
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                                  );
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Enviar Código', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
