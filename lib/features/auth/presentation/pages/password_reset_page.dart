import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../expense/application/auth_cubit.dart';
import '../../../expense/application/auth_state.dart';
import 'login_page.dart';

enum ResetStage { enterEmail, verifyCode, newPassword }

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  ResetStage _currentStage = ResetStage.enterEmail;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // OTP uchun 4ta controller
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  int _timerSeconds = 45;
  Timer? _timer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = "Parolni tiklash";
    if (_currentStage == ResetStage.verifyCode) title = "Tasdiqlash kodi";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (_currentStage == ResetStage.enterEmail) {
              Navigator.pop(context);
            } else {
              setState(() {
                _currentStage = ResetStage.values[_currentStage.index - 1];
              });
            }
          },
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            unauthenticated: () {
              if (_currentStage == ResetStage.newPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Parol muvaffaqiyatli o'zgartirildi!"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
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
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildStageContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_currentStage) {
      case ResetStage.enterEmail:
        return _buildEmailStage();
      case ResetStage.verifyCode:
        return _buildVerifyStage();
      case ResetStage.newPassword:
        return _buildNewPasswordStage();
    }
  }

  // 1-bosqich: Email kiritish
  Widget _buildEmailStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          "Elektron pochtangizga parolni tiklash kodini yuboramiz.",
          style: TextStyle(fontSize: 15, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 32),
        _buildInputField(
          label: "Elektron pochta",
          controller: _emailController,
          hint: "pochta@misol.com",
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 40),
        _buildButton(
          text: "Yuborish",
          onPressed: () {
            if (_emailController.text.isNotEmpty) {
              setState(() => _currentStage = ResetStage.verifyCode);
              _startTimer();
            }
          },
        ),
      ],
    );
  }

  // 2-bosqich: Kodni tasdiqlash
  Widget _buildVerifyStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Elektron pochtangizga yuborilgan 4 raqamli kodni kiriting.",
            style: TextStyle(fontSize: 15, color: Color(0xFF475569)),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) => _buildOtpBox(index)),
        ),
        const SizedBox(height: 48),
        _buildButton(
          text: "Tasdiqlash",
          onPressed: () {
            String code = _otpControllers.map((e) => e.text).join();
            if (code.length == 4) {
              setState(() => _currentStage = ResetStage.newPassword);
            }
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Kodni qayta yuborish ",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            Text(
              "(${_timerSeconds ~/ 60}:${(_timerSeconds % 60).toString().padLeft(2, '0')})",
              style: const TextStyle(
                color: Color(0xFF0D9488),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3-bosqich: Yangi parol
  Widget _buildNewPasswordStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          "Endi yangi parolingizni o'rnating.",
          style: TextStyle(fontSize: 15, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 32),
        _buildInputField(
          label: "Yangi parol",
          controller: _passwordController,
          hint: "********",
          obscureText: true,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          label: "Parolni tasdiqlash",
          controller: _confirmPasswordController,
          hint: "********",
          obscureText: true,
        ),
        const SizedBox(height: 40),
        _buildButton(
          text: "Parolni yangilash",
          onPressed: () {
            if (_passwordController.text == _confirmPasswordController.text &&
                _passwordController.text.length >= 6) {
              context.read<AuthCubit>().resetPassword(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Parollar mos emas yoki juda qisqa"),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
              ? const Color(0xFF0D9488)
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: "",
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 3) {
              _otpFocusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _otpFocusNodes[index - 1].requestFocus();
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
