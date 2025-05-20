import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/person.dart';
import '../models/transaction.dart';

class LedgerProvider with ChangeNotifier {
  final Box<Person> _box = Hive.box<Person>('people');

  int _lastId = 0;
  int _lastTransactionId = 0;

  List<Person> get people => _box.values.toList();

  Person? getPersonById(String id) {
    try {
      return _box.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  int? _getPersonBoxIndexById(String id) {
    final idx = _box.values.toList().indexWhere((p) => p.id == id);
    return idx == -1 ? null : idx;
  }

  void addPerson({
    required String name,
    String? contactId,
    String? phone,
  }) {
    // Avoid duplicate by name and phone (if provided)
    final exists = _box.values.any((p) =>
      p.name.trim().toLowerCase() == name.trim().toLowerCase() &&
      (phone == null || phone.isEmpty || p.phone == phone)
    );
    if (!exists) {
      // Auto-increment id logic
      _lastId = (_box.values.map((p) => int.tryParse(p.id) ?? 0).fold(0, (prev, curr) => curr > prev ? curr : prev)) + 1;
      final person = Person(
        name: name,
        contactId: contactId,
        phone: phone,
        id: _lastId.toString(),
      );
      _box.add(person);
      notifyListeners();
    }
  }

  // Update Person
  void updatePerson(String id, String name, String phone) {
    final idx = _getPersonBoxIndexById(id);
    if (idx != null) {
      final person = _box.getAt(idx);
      if (person != null) {
        person.name = name;
        person.phone = phone;
        person.save(); // important
        notifyListeners();
      }
    }
  }

  // Delete Person
  void deletePerson(String id) {
    final idx = _getPersonBoxIndexById(id);
    if (idx != null) {
      _box.deleteAt(idx);
      notifyListeners();
    }
  }

  void addTransaction(String personId, Transaction tx) {
    final idx = _getPersonBoxIndexById(personId);
    if (idx != null) {
      final person = _box.getAt(idx);
      if (person != null) {
        // Auto-increment transaction id logic
        _lastTransactionId = (person.transactions.map((t) => int.tryParse(t.id) ?? 0).fold(0, (prev, curr) => curr > prev ? curr : prev)) + 1;
        tx.id = _lastTransactionId.toString();
        person.transactions.add(tx);
        person.save(); // important
        notifyListeners();
      }
    }
  }

  // Update Transaction
  void updateTransaction(String personId, String transactionId, Transaction tx) {
    final idx = _getPersonBoxIndexById(personId);
    if (idx != null) {
      final person = _box.getAt(idx);
      if (person != null) {
        final tIndex = person.transactions.indexWhere((t) => t.id == transactionId);
        if (tIndex != -1) {
          person.transactions[tIndex] = tx;
          person.save(); // important
          notifyListeners();
        }
      }
    }
  }

  // Delete Transaction
  void deleteTransaction(String personId, String transactionId) {
    final idx = _getPersonBoxIndexById(personId);
    if (idx != null) {
      final person = _box.getAt(idx);
      if (person != null) {
        final tIndex = person.transactions.indexWhere((t) => t.id == transactionId);
        if (tIndex != -1) {
          person.transactions.removeAt(tIndex);
          person.save(); // important
          notifyListeners();
        }
      }
    }
  }
}
