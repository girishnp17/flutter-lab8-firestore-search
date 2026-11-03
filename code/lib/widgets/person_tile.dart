import 'package:flutter/material.dart';

import '../models/person.dart';

class PersonTile extends StatelessWidget {
  final Person person;

  const PersonTile({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(child: Text(person.name.isNotEmpty ? person.name[0] : '?')),
        title: Text(person.name),
        subtitle: Text('${person.department} • ${person.email}'),
      ),
    );
  }
}
