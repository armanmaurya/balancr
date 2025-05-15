import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/person.dart';
import '../models/transaction.dart';

class LedgerProvider with ChangeNotifier {
  final Box<Person> _box = Hive.box<Person>('people');

  List<Person> get people => _box.values.toList();

  void addPerson(Person person) {
    // Avoid duplicate by name and phone (if provided)
    final exists = _box.values.any((p) =>
      p.name.trim().toLowerCase() == person.name.trim().toLowerCase() &&
      (person.phone == null || person.phone!.isEmpty || p.phone == person.phone)
    );
    if (!exists) {
      _box.add(person);
      notifyListeners();
    }
  }

  // Update Person
  void updatePerson(int index, String name, String phone) {
    final person = _box.getAt(index);
    if (person != null) {
      person.name = name;
      person.phone = phone;
      person.save(); // important
      notifyListeners();
    }
  }

  // Delete Person
  void deletePerson(int index) {
    _box.deleteAt(index);
    notifyListeners();
  }

  void addTransaction(int index, Transaction tx) {
    final person = _box.getAt(index);
    if (person != null) {
      person.transactions.add(tx);
      person.save(); // important
      notifyListeners();
    }
  }

  // Update Transaction
  void updateTransaction(int personIndex, int transactionIndex, Transaction tx) {
    final person = _box.getAt(personIndex);
    if (person != null) {
      person.transactions[transactionIndex] = tx;
      person.save(); // important
      notifyListeners();
    }
  }

  // Delete Transaction
  void deleteTransaction(int personIndex, int transactionIndex) {
    final person = _box.getAt(personIndex);
    if (person != null) {
      person.transactions.removeAt(transactionIndex);
      person.save(); // important
      notifyListeners();
    }
  }
}
