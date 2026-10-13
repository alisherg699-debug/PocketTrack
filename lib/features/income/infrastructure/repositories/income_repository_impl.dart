import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockettrack/features/income/infrastructure/datasources/income_local_data_source.dart';
import 'package:pockettrack/features/income/infrastructure/models/income_model.dart';
import 'package:pockettrack/features/income/domain/entities/income.dart';
import 'package:pockettrack/features/income/domain/repositories/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeLocalDataSource localDataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  IncomeRepositoryImpl(this.localDataSource);

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<List<Income>> getAll() async {
    if (_uid != null) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('incomes')
            .get();

        final remoteIncomes = snapshot.docs.map((doc) {
          final data = doc.data();
          DateTime parseDate(dynamic val) {
            if (val is Timestamp) return val.toDate();
            if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
            return DateTime.now();
          }

          return IncomeModel(
            id: doc.id,
            title: data['title'] ?? '',
            amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
            category: data['category'] ?? '',
            description: data['description'],
            date: parseDate(data['date']),
            createdAt: parseDate(data['createdAt']),
            updatedAt: parseDate(data['updatedAt']),
          ).toEntity();
        }).toList();

        for (var income in remoteIncomes) {
          await localDataSource.add(IncomeModel.fromEntity(income));
        }
        
        return remoteIncomes;
      } catch (e) {
        debugPrint("❌ Firestore'dan daromadlarni olishda xato: $e");
        final models = await localDataSource.getAll();
        return models.map((model) => model.toEntity()).toList();
      }
    }

    final models = await localDataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> add(Income income) async {
    await localDataSource.add(IncomeModel.fromEntity(income));

    if (_uid != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('incomes')
            .doc(income.id)
            .set({
          'title': income.title,
          'amount': income.amount,
          'category': income.category,
          'description': income.description,
          'date': income.date.toIso8601String(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint("✅ Firestore'ga daromad muvaffaqiyatli saqlandi: ${income.id}");
      } catch (e) {
        debugPrint("❌ Firestore'ga daromad saqlashda xato: $e");
      }
    } else {
      debugPrint("❌ Firestore'ga saqlanmadi: _uid null (foydalanuvchi Firebase'ga kirmagan)");
    }
  }

  @override
  Future<void> update(Income income) async {
    await localDataSource.update(IncomeModel.fromEntity(income));

    (income);

    if (_uid != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('incomes')
            .doc(income.id)
            .update({
          'title': income.title,
          'amount': income.amount,
          'category': income.category,
          'description': income.description,
          'date': income.date.toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint("❌ Firestore'da daromadni yangilashda xato: $e");
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);

    if (_uid != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('incomes')
            .doc(id)
            .delete();
      } catch (e) {
        debugPrint("❌ Firestore'dan daromadni o'chirishda xato: $e");
      }
    }
  }
}
