import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';
import 'package:pockettrack/core/utils/category_helper.dart';
import 'package:pockettrack/features/auth/application/auth_cubit.dart';
import 'package:pockettrack/features/auth/application/auth_state.dart';
import 'package:pockettrack/features/expense/application/expense/expense_bloc.dart';
import 'package:pockettrack/features/expense/application/expense/expense_event.dart';
import 'package:pockettrack/features/expense/application/expense/expense_state.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';
import 'package:pockettrack/features/expense/presentation/pages/add_expense_page.dart';
import 'package:pockettrack/features/expense/presentation/pages/expense_details_page.dart';
import 'package:pockettrack/features/expense/presentation/pages/expense_page.dart';
import 'package:pockettrack/features/settings/presentation/pages/profile_page.dart';
import 'package:pockettrack/features/settings/application/settings_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(GetExpenses());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Widget> pages = [
      _HomeContent(onSeeAllPressed: () => setState(() => _currentIndex = 1)),
      const ExpensePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoaded) {
                  final now = DateTime.now();
                  final hasTodayExpenses = state.expenses.any((e) =>
                      e.date.year == now.year &&
                      e.date.month == now.month &&
                      e.date.day == now.day);

                  if (hasTodayExpenses) {
                    return FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddExpensePage(),
                          ),
                        );
                      },
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 30),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF0D9488),
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: l10n.home),
          BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_outlined), label: l10n.expenses),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.profile),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final VoidCallback onSeeAllPressed;
  const _HomeContent({required this.onSeeAllPressed});

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]} '
    );
  }

  Widget _buildHeaderAvatar(String? path) {
    Widget fallbackIcon = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F1),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF0D9488).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 24,
        color: Color(0xFF0D9488),
      ),
    );

    if (path == null || path.trim().isEmpty) {
      return fallbackIcon;
    }

    if (path.startsWith('http')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: Image.network(
            path,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallbackIcon,
          ),
        ),
      );
    }

    if (path.startsWith('assets')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: Image.asset(
            path,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallbackIcon,
          ),
        ),
      );
    }

    final file = File(path);
    if (!file.existsSync()) {
      return fallbackIcon;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.file(
          file,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallbackIcon,
        ),
      ),
    );
  }

  // DINAMIK SALOMLASHISH
  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return l10n.goodMorning;
    if (hour >= 12 && hour < 18) return l10n.goodAfternoon;
    if (hour >= 18 && hour < 24) return l10n.goodEvening;
    return l10n.goodNight;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = context.watch<SettingsCubit>().state.currency;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );
        final userName = user?.firstName ?? l10n.user;

        return BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            final bool isError = state is ExpenseError;
            List<Expense> allExpenses = [];
            List<Expense> todayExpenses = [];
            double todayTotal = 0.0;

            if (state is ExpenseLoaded) {
              allExpenses = state.expenses;
              final now = DateTime.now();
              todayExpenses = allExpenses.where((e) =>
                  e.date.year == now.year && e.date.month == now.month && e.date.day == now.day).toList();
              todayTotal = todayExpenses.fold(0.0, (sum, item) => sum + item.amount);
            }

            return SafeArea(
              child: Column(
                children: [
                  // 1. QOTIB TURUVCHI, UMUMAN QIMIRLAMAYDIGAN STATIK YUQORI APPBAR
                  Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_getGreeting(l10n), style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            Text(userName, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        _buildHeaderAvatar(user?.image),
                      ],
                    ),
                  ),

                  // 2. PASTDAGI MA'LUMOTLAR SCROLL BO'LIB SHU APPBAR TAGIGA KIRIB KETADI
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isError ? const Color(0xFF94A3B8) : const Color(0xFF0D9488),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.todayExpenses, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                const SizedBox(height: 8),
                                Text(
                                  isError ? "--.-- $currencySymbol" : "${_formatCurrency(todayTotal)} $currencySymbol",
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.trending_up, color: Colors.white70, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        todayExpenses.isNotEmpty ? l10n.todayOperationsCount(todayExpenses.length) : l10n.noExpensesToday,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          if (state is ExpenseLoading)
                            const Padding(padding: EdgeInsets.only(top: 100), child: Center(child: CircularProgressIndicator()))
                          else if (isError)
                            _buildErrorState(context, l10n)
                          else if (allExpenses.isEmpty)
                            _buildEmptyState(context, l10n, isNewUser: true)
                          else if (todayExpenses.isEmpty)
                            _buildEmptyState(context, l10n, isNewUser: false)
                          else
                            _buildExpensesList(todayExpenses, l10n),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 40),
          ),
          const SizedBox(height: 24),
          Text(l10n.errorOccurred, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<ExpenseBloc>().add(GetExpenses()),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, {required bool isNewUser}) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3), width: 2),
            ),
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFFF0FDFA), shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF0D9488), size: 40),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isNewUser ? l10n.noExpensesYet : l10n.noExpensesToday,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isNewUser 
                ? l10n.addFirstExpense
                : l10n.addTodayFirstExpense,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpensePage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Text(l10n.addExpense, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.todayOperations, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            TextButton(
              onPressed: onSeeAllPressed,
              child: Text(l10n.seeAll, style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return GestureDetector(
              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseDetailsPage(expense: expense))); },
              child: _ExpenseItem(expense: expense, formatCurrency: _formatCurrency, l10n: l10n),
            );
          },
        ),
      ],
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final Expense expense;
  final String Function(double) formatCurrency;
  final AppLocalizations l10n;
  const _ExpenseItem({required this.expense, required this.formatCurrency, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.watch<SettingsCubit>().state.currency;
    final icon = CategoryHelper.getIconForCategory(expense.category);
    final iconColor = CategoryHelper.getColorForCategory(expense.category);
    final localizedCategory = CategoryHelper.getLocalizedName(expense.category, l10n);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text("$localizedCategory  •  ${DateFormat('hh:mm a').format(expense.date)}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ],
            ),
          ),
          Text("- ${formatCurrency(expense.amount)} $currencySymbol", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
