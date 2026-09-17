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
          return IncomeModel.fromJson({...data, 'id': doc.id}).toEntity();
        }).toList();

        for (var income in remoteIncomes) {
          await localDataSource.add(IncomeModel.fromEntity(income));
        }
        
        return remoteIncomes;
      } catch (e) {
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
    }
  }

  @override
  Future<void> update(Income income) async {
    await localDataSource.update(IncomeModel.fromEntity(income));

    if (_uid != null) {
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
    }
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);

    if (_uid != null) {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('incomes')
          .doc(id)
          .delete();
    }
  }
}
