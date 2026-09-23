import 'package:flutter/material.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';

class CategoryHelper {
  static IconData getIconForCategory(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('oziq') || lower.contains('food') || lower.contains('продукт')) {
      return Icons.restaurant;
    } else if (lower.contains('transport') || lower.contains('транспорт')) {
      return Icons.directions_car;
    } else if (lower.contains('xarid') || lower.contains('shop') || lower.contains('покуп')) {
      return Icons.shopping_bag_outlined;
    } else if (lower.contains('to\'lov') || lower.contains('tolov') || lower.contains('pay') || lower.contains('платеж')) {
      return Icons.credit_card;
    } else if (lower.contains('salo') || lower.contains('health') || lower.contains('здоров')) {
      return Icons.favorite_border;
    } else if (lower.contains('oylik') || lower.contains('maosh') || lower.contains('salar') || lower.contains('зарплат')) {
      return Icons.account_balance_wallet_outlined;
    } else if (lower.contains('free') || lower.contains('фриланс')) {
      return Icons.laptop_mac;
    } else if (lower.contains('invest') || lower.contains('инвест')) {
      return Icons.trending_up;
    } else if (lower.contains('sovg') || lower.contains('gift') || lower.contains('подар')) {
      return Icons.card_giftcard;
    }
    return Icons.label_outline;
  }

  static Color getColorForCategory(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('oziq') || lower.contains('food') || lower.contains('продукт')) {
      return Colors.orange;
    } else if (lower.contains('transport') || lower.contains('транспорт')) {
      return Colors.blue;
    } else if (lower.contains('xarid') || lower.contains('shop') || lower.contains('покуп')) {
      return Colors.purple;
    } else if (lower.contains('to\'lov') || lower.contains('tolov') || lower.contains('pay') || lower.contains('платеж')) {
      return Colors.teal;
    } else if (lower.contains('salo') || lower.contains('health') || lower.contains('здоров')) {
      return Colors.pink;
    }
    return const Color(0xFF0D9488);
  }

  static String getLocalizedName(String categoryName, AppLocalizations l10n) {
    final lower = categoryName.toLowerCase();
    if (lower == 'oziq-ovqat' || lower == 'food' || lower == 'продукты' || lower == l10n.food.toLowerCase()) return l10n.food;
    if (lower == 'transport' || lower == 'транспорт' || lower == l10n.transport.toLowerCase()) return l10n.transport;
    if (lower == 'xaridlar' || lower == 'shopping' || lower == 'покупки' || lower == l10n.shopping.toLowerCase()) return l10n.shopping;
    if (lower == 'to\'lovlar' || lower == 'tolovlar' || lower == 'payments' || lower == 'платежи' || lower == l10n.payments.toLowerCase()) return l10n.payments;
    if (lower == 'salomatlik' || lower == 'health' || lower == 'здоровье' || lower == l10n.health.toLowerCase()) return l10n.health;
    if (lower == 'boshqa' || lower == 'other' || lower == 'другое' || lower == l10n.other.toLowerCase()) return l10n.other;
    return categoryName;
  }
}
