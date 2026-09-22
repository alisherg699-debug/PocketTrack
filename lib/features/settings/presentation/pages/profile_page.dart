import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pockettrack/features/auth/application/auth_cubit.dart';
import 'package:pockettrack/features/auth/application/auth_state.dart';
import 'package:pockettrack/features/auth/presentation/pages/login_page.dart';
import 'package:pockettrack/features/settings/presentation/pages/account_settings_page.dart';
import 'package:pockettrack/features/settings/presentation/pages/notifications_page.dart';
import 'package:pockettrack/features/settings/presentation/pages/categories_page.dart';
import 'package:pockettrack/features/settings/presentation/pages/security_page.dart';

import 'package:pockettrack/core/l10n/app_localizations.dart';
import 'help_support_page.dart';
import 'language_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          unauthenticated: () {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final user = state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              l10n.profile,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: const Color(0xFFE2E8F0),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _buildImage(user?.image),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.firstName ?? l10n.loading,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? "",
                        style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12, top: 12),
                        child: Text(
                          l10n.settings.toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: l10n.accountSettings,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsPage()));
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: l10n.categories,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesPage()));
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.notifications_none,
                        title: l10n.notifications,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        title: l10n.security,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPage()));
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.language_outlined,
                        title: l10n.changeLanguage,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguagePage()));
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: l10n.helpSupport,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage()));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildLogoutButton(l10n),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF1E293B), size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: ListTile(
        onTap: () => _showLogoutDialog(l10n),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.logout, color: Colors.red, size: 22),
        ),
        title: Text(l10n.logout, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red)),
      ),
    );
  }

  void _showLogoutDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.logout),
        content: Text(l10n.confirmLogout),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.pop(context);
            },
            child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
