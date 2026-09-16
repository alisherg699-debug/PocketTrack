import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../expense/application/auth_cubit.dart';
import '../../../expense/application/auth_state.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _currencyController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    final user = authState.maybeWhen(
      authenticated: (user) => user,
      orElse: () => null,
    );

    _nameController = TextEditingController(text: user?.firstName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '+998 90 123 45 67');
    _currencyController = TextEditingController(text: user?.currency ?? 'so\'m');
    _imagePath = user?.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  ImageProvider _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/iconspng/avatar.png');
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets')) {
      return AssetImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Hisob sozlamalari", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFE2E8F0),
                        backgroundImage: _buildImage(_imagePath),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0D9488),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text(
                      "Rasm o'zgartirish",
                      style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildInputField(label: "To'liq ism", controller: _nameController, hint: "Alisher Karimov"),
                  const SizedBox(height: 20),
                  _buildInputField(label: "Elektron pochta", controller: _emailController, hint: "alisher@email.com", keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildInputField(label: "Telefon raqam", controller: _phoneController, hint: "+998 90 123 45 67", keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildInputField(label: "Valyuta", controller: _currencyController, hint: "so'm"),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              state.maybeWhen(
                authenticated: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profil muvaffaqiyatli yangilandi!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message), backgroundColor: Colors.red),
                  );
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              final bool isUpdating = state.maybeWhen(loading: () => true, orElse: () => false);

              return ElevatedButton(
                onPressed: isUpdating ? null : () {
                  if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ism va email bo'sh bo'lishi mumkin emas"), backgroundColor: Colors.orange),
                    );
                    return;
                  }

                  context.read<AuthCubit>().updateProfile(
                    _nameController.text.trim(),
                    _emailController.text.trim(),
                    phone: _phoneController.text.trim(),
                    currency: _currencyController.text.trim(),
                    imagePath: _imagePath,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isUpdating 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Saqlash", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required String hint, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
            decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18)),
          ),
        ),
      ],
    );
  }
}
