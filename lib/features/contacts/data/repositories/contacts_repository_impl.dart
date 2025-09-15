import '../../domain/entities/contact_entity.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../datasources/contact_remote_datasource.dart';
import '../models/contact_model.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addContact(ContactEntity contact) async {
    final model = ContactModel.fromEntity(contact);
    await remoteDataSource.addContact(model);
  }

  @override
  Future<void> deleteContact(String contactId) async {
    await remoteDataSource.deleteContact(contactId);
  }

  @override
  Future<List<ContactEntity>> getContacts() async {
    final models = await remoteDataSource.getContacts();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ContactEntity>> searchContacts(String query) async {
    final models = await remoteDataSource.searchContacts(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> updateContact(ContactEntity contact) async {
    final model = ContactModel.fromEntity(contact);
    await remoteDataSource.updateContact(model);
  }
}
