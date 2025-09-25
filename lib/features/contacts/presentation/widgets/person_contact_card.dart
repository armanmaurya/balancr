import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class PersonContactCard extends StatelessWidget {
  final String displayName;
  final Contact contact;
  const PersonContactCard({
    super.key,
    required this.displayName,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            // Fetch full contact details on-demand to get phone numbers
            Contact full;
            try {
              full =
                  await FlutterContacts.getContact(
                    contact.id,
                    withProperties: true,
                  ) ??
                  contact;
            } catch (_) {
              full = contact;
            }
            if (!context.mounted) return;
            context.push(
              "/add_contact?name=${Uri.encodeComponent(displayName)}${full.phones.isNotEmpty ? '&phone=${Uri.encodeComponent(full.phones.first.number)}' : ''}",
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.blue[700], size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Avoid forcing phones to load in list item; show only if present on lightweight object
                      if (contact.phones.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            contact.phones.first.number,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
