import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/person.dart';
import '../models/transaction.dart';

class LedgerProvider with ChangeNotifier {
  final Box<Person> _box = Hive.box<Person>('people');

  List<Person> get people => _box.values.toList();

  void addPerson(String name) {
    _box.add(Person(name: name));
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

  void deletePerson(int index) {
    _box.deleteAt(index);
    notifyListeners();
  }
}
