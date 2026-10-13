import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';
import 'package:pockettrack/core/utils/category_helper.dart';

class CategoryItem {
  final String title;
  final String emoji;

  CategoryItem({required this.title, required this.emoji});

  Map<String, dynamic> toMap() => {'title': title, 'emoji': emoji};

  factory CategoryItem.fromMap(Map<String, dynamic> map) => CategoryItem(
    title: map['title'] ?? '',
    emoji: map['emoji'] ?? (map['iconCode'] != null ? '📁' : '📁'),
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
  final TextEditingController _emojiController = TextEditingController(text: '🍕');

  String selectedEmoji = '🍕';
  final List<String> emojiOptions = [
    '🍕', '🚗', '🛍️', '💳', '❤️', '🏠', '🎬', '🏋️', '💼', '📚',
    '⛽', '✈️', '💊', '🔧', '🎁', '🍔', '☕', '💡', '📱', '💰',
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
        setState(() {
          categories = [];
        });
      }
    } catch (e) {
      setState(() {
        categories = [];
      });
    }
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
    await CategoryHelper.loadCustomCategories();
  }

  void _addOrUpdateCategory(BuildContext dialogContext, {int? index}) {
    if (_categoryController.text.isNotEmpty) {
      setState(() {
        final newItem = CategoryItem(
          title: _categoryController.text.trim(),
          emoji: _emojiController.text.trim().isNotEmpty ? _emojiController.text.trim() : selectedEmoji,
        );
        if (index != null) {
          categories[index] = newItem;
        } else {
          categories.add(newItem);
        }
        _categoryController.clear();
        _emojiController.text = '🍕';
        selectedEmoji = '🍕';
      });
      _saveCategories();
      Navigator.pop(dialogContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.categories,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1E293B)),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noData,
                    style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = categories[index];
                return _buildCategoryCard(item, index, isDark);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          selectedEmoji = '🍕';
          _emojiController.text = '🍕';
          _showCategoryDialog(isDark: isDark);
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
        lower == l10n.food.toLowerCase()) {
      return l10n.food;
    }
    if (lower == 'transport' ||
        lower == 'транспорт' ||
        lower == l10n.transport.toLowerCase()) {
      return l10n.transport;
    }
    if (lower == 'xaridlar' ||
        lower == 'shopping' ||
        lower == 'покупки' ||
        lower == l10n.shopping.toLowerCase()) {
      return l10n.shopping;
    }
    if (lower == 'to\'lovlar' ||
        lower == 'tolovlar' ||
        lower == 'payments' ||
        lower == 'платежи' ||
        lower == l10n.payments.toLowerCase()) {
      return l10n.payments;
    }
    if (lower == 'salomatlik' ||
        lower == 'health' ||
        lower == 'здоровье' ||
        lower == l10n.health.toLowerCase()) {
      return l10n.health;
    }
    if (lower == 'boshqa' ||
        lower == 'other' ||
        lower == 'другое' ||
        lower == l10n.health.toLowerCase()) {
      return l10n.other;
    }
    return cat;
  }

  Widget _buildCategoryCard(CategoryItem item, int index, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final displayTitle = _getLocalizedCategoryName(item.title, l10n);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFF0D9488).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(
          displayTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1E293B)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note, color: Color(0xFF94A3B8)),
              onPressed: () {
                selectedEmoji = item.emoji;
                _emojiController.text = item.emoji;
                _showCategoryDialog(index: index, initialValue: item.title, initialEmoji: item.emoji, isDark: isDark);
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

  void _showCategoryDialog({int? index, String? initialValue, String? initialEmoji, required bool isDark}) {
    final l10n = AppLocalizations.of(context)!;
    _categoryController.text = initialValue ?? "";
    _emojiController.text = initialEmoji ?? selectedEmoji;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category_outlined, color: Color(0xFF0D9488), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  index == null ? l10n.newCategory : l10n.editCategory,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _emojiController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedEmoji = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _categoryController,
                        autofocus: true,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          hintText: l10n.categoryName,
                          hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.selectIcon,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: emojiOptions.map((emoji) {
                      bool isSel = selectedEmoji == emoji;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedEmoji = emoji;
                            _emojiController.text = emoji;
                          });
                          setState(() {
                            selectedEmoji = emoji;
                            _emojiController.text = emoji;
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF0D9488).withValues(alpha: 0.15) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? const Color(0xFF0D9488) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(l10n.cancel, style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () => _addOrUpdateCategory(dialogContext, index: index),
                    child: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
