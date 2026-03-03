
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/core/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isValid = false;

  void _onChanged(String value) {
    setState(() {
      _isValid = value.length == 10;
    });
  }

  Future<void> _sendOtp() async {
    if (!_isValid) return;

    setState(() => _isLoading = true);
    try {
      final phone = '+52${_phoneController.text}';
      await Supabase.instance.client.auth.signInWithOtp(
        phone: phone,
      );
      if (mounted) {
        context.push('/otp?phone=${Uri.encodeComponent(phone)}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa tu número de celular para continuar',
                style: TextStyle(color: AppColors.text.withOpacity(0.7), fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3136),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _phoneController,
                  onChanged: _onChanged,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(color: AppColors.text, fontSize: 18),
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('+52 ', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    hintText: 'Número a 10 dígitos',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isValid && !_isLoading) ? _sendOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Enviar código', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
