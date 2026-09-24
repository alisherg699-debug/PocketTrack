import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';

class CategoryItem {
  final String title;
  final IconData icon;

  CategoryItem({required this.title, required this.icon});

  Map<String, dynamic> toMap() => {'title': title, 'iconCode': icon.codePoint};

  factory CategoryItem.fromMap(Map<String, dynamic> map) => CategoryItem(
    title: map['title'],
    icon: IconData(map['iconCode'], fontFamily: 'MaterialIcons'),
  );
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryItem> categories = [];
  final TextEditingController _categoryController = TextEditingController();

  IconData selectedIcon = Icons.label_outline;
  final List<IconData> iconOptions = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag_outlined,
    Icons.credit_card,
    Icons.favorite_border,
    Icons.home_outlined,
    Icons.movie_outlined,
    Icons.fitness_center,
    Icons.work_outline,
    Icons.school_outlined,
    Icons.local_gas_station,
    Icons.flight_takeoff,
    Icons.medical_services_outlined,
    Icons.build_outlined,
    Icons.card_giftcard,
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedData = prefs.getStringList('custom_categories_v2');

    try {
      if (savedData != null && savedData.isNotEmpty) {
        setState(() {
          categories = savedData
              .map((s) => CategoryItem.fromMap(jsonDecode(s)))
              .toList();
        });
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          _setInitialCategories(l10n);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _setInitialCategories(l10n);
      }
    }
  }

  void _setInitialCategories(AppLocalizations l10n) {
    setState(() {
      categories = [
        CategoryItem(title: l10n.food, icon: Icons.restaurant),
        CategoryItem(title: l10n.transport, icon: Icons.directions_car),
        CategoryItem(title: l10n.shopping, icon: Icons.shopping_bag_outlined),
        CategoryItem(title: l10n.payments, icon: Icons.credit_card),
        CategoryItem(title: l10n.health, icon: Icons.favorite_border),
        CategoryItem(title: l10n.other, icon: Icons.label_outline),
      ];
    });
    _saveCategories();
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> dataToSave = categories
        .map((c) => jsonEncode(c.toMap()))
        .toList();
    await prefs.setStringList('custom_categories_v2', dataToSave);
    await prefs.setStringList(
      'custom_categories',
      categories.map((c) => c.title).toList(),
    );
  }

  void _addOrUpdateCategory({int? index}) {
    if (_categoryController.text.isNotEmpty) {
      setState(() {
        final newItem = CategoryItem(
          title: _categoryController.text.trim(),
          icon: selectedIcon,
        );
        if (index != null) {
          categories[index] = newItem;
        } else {
          categories.add(newItem);
        }
        _categoryController.clear();
      });
      _saveCategories();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          l10n.categories,
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
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = categories[index];
          return _buildCategoryCard(item, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectedIcon = Icons.label_outline;
          _showCategoryDialog();
        },
        backgroundColor: const Color(0xFF064E3B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  String _getLocalizedCategoryName(String cat, AppLocalizations l10n) {
    final lower = cat.toLowerCase();
    if (lower == 'oziq-ovqat' ||
        lower == 'food' ||
        lower == 'продукты' ||
        lower == l10n.food.toLowerCase())
      return l10n.food;
    if (lower == 'transport' ||
        lower == 'транспорт' ||
        lower == l10n.transport.toLowerCase())
      return l10n.transport;
    if (lower == 'xaridlar' ||
        lower == 'shopping' ||
        lower == 'покупки' ||
        lower == l10n.shopping.toLowerCase())
      return l10n.shopping;
    if (lower == 'to\'lovlar' ||
        lower == 'tolovlar' ||
        lower == 'payments' ||
        lower == 'платежи' ||
        lower == l10n.payments.toLowerCase())
      return l10n.payments;
    if (lower == 'salomatlik' ||
        lower == 'health' ||
        lower == 'здоровье' ||
        lower == l10n.health.toLowerCase())
      return l10n.health;
    if (lower == 'boshqa' ||
        lower == 'other' ||
        lower == 'другое' ||
        lower == l10n.other.toLowerCase())
      return l10n.other;
    return cat;
  }

  Widget _buildCategoryCard(CategoryItem item, int index) {
    final l10n = AppLocalizations.of(context)!;
    final displayTitle = _getLocalizedCategoryName(item.title, l10n);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: const Color(0xFF0D9488), size: 22),
        ),
        title: Text(
          displayTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note, color: Color(0xFF94A3B8)),
              onPressed: () {
                selectedIcon = item.icon;
                _showCategoryDialog(index: index, initialValue: item.title);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              onPressed: () {
                setState(() {
                  categories.removeAt(index);
                });
                _saveCategories();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog({int? index, String? initialValue}) {
    final l10n = AppLocalizations.of(context)!;
    _categoryController.text = initialValue ?? "";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(index == null ? l10n.newCategory : l10n.editCategory),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.categoryName,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.selectIcon,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                width: double.maxFinite,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: iconOptions.length,
                  itemBuilder: (context, i) {
                    bool isSel = selectedIcon == iconOptions[i];
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedIcon = iconOptions[i];
                        });
                        setState(() {
                          selectedIcon = iconOptions[i];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? const Color(0xFF0D9488)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Icon(
                          iconOptions[i],
                          color: isSel ? Colors.white : Colors.black54,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _addOrUpdateCategory(index: index),
              child: Text(
                l10n.save,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
