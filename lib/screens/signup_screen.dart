import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'phone_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              Text('Sign up to start splitting expenses.', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMed)),
              const SizedBox(height: 32),
              _inputField('FULL NAME', 'Aditi Sharma', controller: _nameController),
              const SizedBox(height: 20),
              _inputField('EMAIL', 'aditi@example.com', controller: _emailController),
              const SizedBox(height: 20),
              _inputField('PHONE NUMBER', '91XXXXXXXXXX', controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _inputField('PASSWORD', '••••••••', controller: _passwordController, obscure: true),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  if (_phoneController.text.length >= 10) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhoneVerificationScreen(
                          phoneNumber: _phoneController.text,
                          name: _nameController.text,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text('Sign Up', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, {bool obscure = false, TextEditingController? controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textLight, letterSpacing: 1.1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: AppTheme.textLight, fontSize: 15),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
          ),
        ),
      ],
    );
  }
}
