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
          return ExpenseModel.fromJson({...data, 'id': doc.id}).toEntity();
        }).toList();

        // 2. Lokal bazani (Hive) yangilab qo'yamiz (Offline ishlashi uchun)
        for (var expense in remoteExpenses) {
          await localDataSource.add(ExpenseModel.fromEntity(expense));
        }
        
        return remoteExpenses;
      } catch (e) {
        // Xatolik bo'lsa (masalan, internet yo'q), lokal bazadan qaytaramiz
        final models = await localDataSource.getAll();
        return models.map((model) => model.toEntity()).toList();
      }
    }

    // Tizimga kirmagan bo'lsa, faqat lokal
    final models = await localDataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> add(Expense expense) async {
    // 1. Lokal bazaga yozamiz
    await localDataSource.add(ExpenseModel.fromEntity(expense));

    // 2. Firestore'ga yozamiz
    if (_uid != null) {
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
    }
  }

  @override
  Future<void> update(Expense expense) async {
    await localDataSource.update(ExpenseModel.fromEntity(expense));

    if (_uid != null) {
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
    }
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);

    if (_uid != null) {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('expenses')
          .doc(id)
          .delete();
    }
  }
}
