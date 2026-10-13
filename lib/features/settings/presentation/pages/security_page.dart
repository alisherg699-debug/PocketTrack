import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _storage = const FlutterSecureStorage();
  bool _isPinEnabled = false;
  bool _isBiometricEnabled = true;
  String _autoLockDuration = "5 daqiqa";
  bool _hasOtherSessions = true;
  String _deviceName = "Ushbu qurilma";

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
    _initDeviceInfo();
  }

  Future<void> _loadSecuritySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = await _storage.read(key: 'user_pin');
    if (!mounted) return;
    setState(() {
      _isPinEnabled = pin != null;
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? true;
      _autoLockDuration = prefs.getString('auto_lock_duration') ?? "5 daqiqa";
      _hasOtherSessions = prefs.getBool('has_other_sessions') ?? true;
    });
  }

  Future<void> _initDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        if (!mounted) return;
        setState(() {
          _deviceName = "${androidInfo.brand} ${androidInfo.model}";
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        if (!mounted) return;
        setState(() {
          _deviceName = iosInfo.name.isNotEmpty ? iosInfo.name : iosInfo.model;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleBiometric(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
    if (!mounted) return;
    setState(() {
      _isBiometricEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? l10n.biometricEnabled : l10n.biometricDisabled),
        backgroundColor: const Color(0xFF0D9488),
      ),
    );
  }

  void _showAutoLockDialog(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final options = ["Darhol", "1 daqiqa", "5 daqiqa", "15 daqiqa", "30 daqiqa"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.autoLock,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => ListTile(
                  title: Text(option, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B))),
                  trailing: _autoLockDuration == option ? const Icon(Icons.check, color: Color(0xFF0D9488)) : null,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('auto_lock_duration', option);
                    if (!mounted) return;
                    setState(() {
                      _autoLockDuration = option;
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showAllSessionsDialog(bool isDark) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.allSessions, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Platform.isIOS ? Icons.phone_iphone_rounded : Icons.phone_android_rounded, color: const Color(0xFF0D9488)),
              title: Text(_deviceName, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
              subtitle: Text(l10n.currentDeviceSubtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: Text(l10n.current, style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            if (_hasOtherSessions) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.laptop_mac_rounded, color: Colors.grey),
                title: Text("MacBook Pro", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                subtitle: const Text("Samarqand · 2 kun oldin", style: TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_other_sessions', false);
                    if (!mounted) return;
                    setState(() {
                      _hasOtherSessions = false;
                    });
                    if (!mounted) return;
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.sessionClosed), backgroundColor: const Color(0xFF0D9488)),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: const TextStyle(color: Color(0xFF0D9488))),
          ),
        ],
      ),
    );
  }

  void _logoutOtherSessions() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.allOtherSessions, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B))),
        content: Text(l10n.confirmLogoutOtherSessions, style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF1E293B))),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('has_other_sessions', false);
              if (!mounted) return;
              setState(() {
                _hasOtherSessions = false;
              });
              if (!mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.loggedOutOtherSessions), backgroundColor: const Color(0xFF0D9488)),
              );
            },
            child: Text(l10n.logOut, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSetPinDialog(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final List<TextEditingController> controllers = List.generate(4, (_) => TextEditingController());
    final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF0D9488),
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.setPin,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.securityDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF94A3B8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) => SizedBox(
                  width: 55,
                  height: 60,
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    obscureText: true,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        focusNodes[index - 1].requestFocus();
                      }
                      setDialogState(() {});
                    },
                  ),
                )),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  bool filled = controllers[index].text.isNotEmpty;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? const Color(0xFF0D9488) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        String pin = controllers.map((e) => e.text).join();
                        if (pin.length == 4) {
                          await _storage.write(key: 'user_pin', value: pin);
                          if (!mounted) return;
                          setState(() {
                            _isPinEnabled = true;
                          });
                          if (context.mounted) Navigator.pop(context);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.savedSuccessfully),
                                backgroundColor: const Color(0xFF0D9488),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        l10n.save,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.security,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1E293B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Kirish himoyasi
            Text(
              l10n.loginProtection,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // 1. PIN-kod
            _buildSecurityCard(
              context,
              icon: Icons.key_rounded,
              iconBgColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
              iconColor: const Color(0xFF0D9488),
              title: l10n.pinCode,
              subtitle: l10n.pinCodeSubtitle,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isPinEnabled ? l10n.enabled : l10n.disabled,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isPinEnabled ? const Color(0xFF0D9488) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
              onTap: () => _showSetPinDialog(isDark),
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // 2. Biometrik kirish
            _buildSecurityCard(
              context,
              icon: Icons.fingerprint_rounded,
              iconBgColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
              iconColor: const Color(0xFF0D9488),
              title: l10n.biometricLogin,
              subtitle: l10n.biometricSubtitle,
              trailing: Switch.adaptive(
                value: _isBiometricEnabled,
                activeTrackColor: const Color(0xFF0D9488),
                onChanged: _toggleBiometric,
              ),
              onTap: () => _toggleBiometric(!_isBiometricEnabled),
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // 3. Avtomatik qulflash
            _buildSecurityCard(
              context,
              icon: Icons.timer_outlined,
              iconBgColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
              iconColor: const Color(0xFF0D9488),
              title: l10n.autoLock,
              subtitle: l10n.autoLockSubtitle,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _autoLockDuration,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
              onTap: () => _showAutoLockDialog(isDark),
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Section 2: Seanslar va qurilmalar
            Text(
              l10n.sessionsAndDevices,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // 4. Ushbu qurilma (Dynamic Device Name)
            _buildSecurityCard(
              context,
              icon: Platform.isIOS ? Icons.phone_iphone_rounded : Icons.phone_android_rounded,
              iconBgColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
              iconColor: const Color(0xFF0D9488),
              title: _deviceName,
              subtitle: l10n.currentDeviceSubtitle,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.current,
                  style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // 5. Barcha seanslar
            _buildSecurityCard(
              context,
              icon: Icons.devices_rounded,
              iconBgColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
              iconColor: const Color(0xFF0D9488),
              title: l10n.allSessions,
              subtitle: l10n.allSessionsSubtitle,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_hasOtherSessions)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(l10n.otherSessionBadge, style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
              onTap: () => _showAllSessionsDialog(isDark),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: Color(0xFF0D9488), size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.encryptionInfo,
                      style: TextStyle(color: isDark ? const Color(0xFF99F6E4) : const Color(0xFF0F766E), fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom logout other sessions button
            Center(
              child: TextButton(
                onPressed: _logoutOtherSessions,
                child: Text(
                  l10n.logoutOtherSessions,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}
