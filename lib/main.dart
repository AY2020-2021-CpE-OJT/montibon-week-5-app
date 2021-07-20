import 'package:flutter/material.dart';
import 'package:phonebook_app/Activities/display_contacts.dart';
import 'package:phonebook_app/Activities/display_contacts_revision.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phonebook Application',
      home: PhonebookDisplay2(),
      );
  }
}
