import '../entities/contact_entity.dart';

abstract class ContactsRepository {
  /// Add a new contact for the current user
  Future<void> addContact(ContactEntity contact);

  /// Get all contacts of the current user
  Future<List<ContactEntity>> getContacts();

  /// Search contacts by name
  Future<List<ContactEntity>> searchContacts(String query);

  /// Delete a contact by its ID
  Future<void> deleteContact(String contactId);

  /// Update an existing contact
  Future<void> updateContact(ContactEntity contact);
}
