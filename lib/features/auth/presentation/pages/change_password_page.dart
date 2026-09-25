import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockettrack/features/auth/application/auth_cubit.dart';
import 'package:pockettrack/features/auth/application/auth_state.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _oldVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  // Parol talablari
  bool has8Chars = false;
  bool hasUppercase = false;
  bool hasDigits = false;
  bool hasSpecial = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _newPasswordController.text;
    setState(() {
      has8Chars = password.length >= 8;
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasDigits = password.contains(RegExp(r'[0-9]'));
      hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _handleChange() {
    final l10n = AppLocalizations.of(context)!;
    if (has8Chars && hasUppercase && hasDigits && hasSpecial) {
      if (_newPasswordController.text == _confirmPasswordController.text) {
        context.read<AuthCubit>().changePassword(
          _oldPasswordController.text.trim(),
          _newPasswordController.text.trim(),
        );
      } else {
        _showSnack(l10n.passwordsDoNotMatch, Colors.red);
      }
    } else {
      _showSnack(l10n.passwordsInvalid, Colors.orange);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    int strengthCount = [
      has8Chars,
      hasUppercase,
      hasDigits,
      hasSpecial,
    ].where((e) => e).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          l10n.changePassword,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            authenticated: (_) {
              _showSnack(l10n.passwordChangedSuccess, Colors.green);
              Navigator.pop(context);
            },
            error: (msg) => _showSnack(msg, Colors.red),
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(l10n.currentPassword),
                _buildField(
                  _oldPasswordController,
                  _oldVisible,
                  (val) => setState(() => _oldVisible = !val),
                ),
                const SizedBox(height: 24),

                _buildLabel(l10n.newPassword),
                _buildField(
                  _newPasswordController,
                  _newVisible,
                  (val) => setState(() => _newVisible = !val),
                  isNew: true,
                ),
                const SizedBox(height: 12),

                // STRENGTH INDICATOR
                Row(
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                        decoration: BoxDecoration(
                          color: index < strengthCount
                              ? const Color(0xFF0D9488)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strengthCount == 4
                      ? l10n.strong
                      : (strengthCount >= 2 ? l10n.medium : l10n.weak),
                  style: TextStyle(
                    color: strengthCount == 4
                        ? const Color(0xFF0D9488)
                        : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel(l10n.confirmPassword),
                _buildField(
                  _confirmPasswordController,
                  _confirmVisible,
                  (val) => setState(() => _confirmVisible = !val),
                  hint: "Yangi parolni qayta kiriting",
                ),

                const SizedBox(height: 32),
                _buildRequirement(l10n.min8Chars, has8Chars),
                _buildRequirement(l10n.uppercase, hasUppercase),
                _buildRequirement(l10n.digit, hasDigits),
                _buildRequirement(l10n.specialChar, hasSpecial),

                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          l10n.save,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    bool visible,
    Function(bool) toggle, {
    bool isNew = false,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNew && controller.text.isNotEmpty
              ? const Color(0xFF0D9488)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: !visible,
        decoration: InputDecoration(
          hintText: hint ?? "********",
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              visible ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF94A3B8),
            ),
            onPressed: () => toggle(visible),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 20,
            color: isMet ? const Color(0xFF0D9488) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isMet ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
