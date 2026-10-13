import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockettrack/features/expense/infrastructure/datasources/expense_local_data_source.dart';
import 'package:pockettrack/features/expense/infrastructure/models/expense_model.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';
import 'package:pockettrack/features/expense/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ExpenseRepositoryImpl(this.localDataSource);

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<List<Expense>> getAll() async {
    // 1. Agar foydalanuvchi tizimga kirgan bo'lsa, Firestore'dan ma'lumotlarni olamiz
    if (_uid != null) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('expenses')
            .get();

        final remoteExpenses = snapshot.docs.map((doc) {
          final data = doc.data();
          DateTime parseDate(dynamic val) {
            if (val is Timestamp) return val.toDate();
            if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
            return DateTime.now();
          }

          return ExpenseModel(
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

        for (var expense in remoteExpenses) {
          await localDataSource.add(ExpenseModel.fromEntity(expense));
        }
        
        return remoteExpenses;
      } catch (e) {
        debugPrint("❌Firestore'dan xarajatlarni olishda xato: $e");
        final models = await localDataSource.getAll();
        return models.map((model) => model.toEntity()).toList();
      }
    }

    final models = await localDataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> add(Expense expense) async {
    await localDataSource.add(ExpenseModel.fromEntity(expense));

    if (_uid != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('expenses')
            .doc(expense.id)
            .set({
          'title': expense.title,
          'amount': expense.amount,
          'category': expense.category,
          'description': expense.description,
          'date': expense.date.toIso8601String(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint("✅ Firestore'ga xarajat muvaffaqiyatli saqlandi: ${expense.id}");
      } catch (e) {
        debugPrint("❌ Firestore'ga xarajat saqlashda xato: $e");
      }
    } else {
      debugPrint("❌ Firestore'ga saqlanmadi: _uid null (foydalanuvchi Firebase'ga kirmagan)");
    }
  }

  @override
  Future<void> update(Expense expense) async {
    await localDataSource.update(ExpenseModel.fromEntity(expense));

    if (_uid != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('expenses')
            .doc(expense.id)
            .update({
          'title': expense.title,
          'amount': expense.amount,
          'category': expense.category,
          'description': expense.description,
          'date': expense.date.toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint("❌ Firestore'da xarajatni yangilashda xato: $e");
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
            .collection('expenses')
            .doc(id)
            .delete();
      } catch (e) {
        debugPrint("❌ Firestore'dan xarajatni o'chirishda xato: $e");
      }
    }
  }
}
