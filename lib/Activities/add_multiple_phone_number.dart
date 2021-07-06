import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import '../DataModel.dart';
import 'display_contacts.dart';


class AddPhonebook extends StatefulWidget {

  @override
  _AddPhonebookState createState() => _AddPhonebookState();
}

class _AddPhonebookState extends State<AddPhonebook> {

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  List<TextEditingController> _phoneNumbersController = [];

  late DataModel _user;

  int counter = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add to Phonebook'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0.0,
      ),

      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15),
                hintText: 'Enter first name',
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  hintText: 'Enter last name'
              ),
            ),
            Flexible(child: ListView.builder(
                shrinkWrap: true,
                itemCount: counter,
                itemBuilder: (context , index){
                  _phoneNumbersController.add(TextEditingController());
                  return dynamicPhoneNumber(index);
                },
                ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size.fromWidth(500)),
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: (){
                  setState(() {
                    counter++;
                  });
                },
                child: Text('Add Another Phone Number')),
            SizedBox(height: 20),
            ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size.fromWidth(500)),
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async {

                  List <dynamic> phoneNumbers = [];
                  String firstName = _firstNameController.text;
                  String lastName = _lastNameController.text;
                  _firstNameController.clear();
                  _lastNameController.clear();

                  for (int i = 0; i < counter; i++) {
                    phoneNumbers.add(_phoneNumbersController[i].text.toString());
                    _phoneNumbersController[i].clear();
                  }

                  final DataModel? user = await createUser(firstName, lastName, phoneNumbers);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PhonebookDisplay()));

                  setState(() {
                    _user = user!;

                  });
                },
                child: Text('Save')),
          ],
        ),
      ),
    );
  }

  dynamicPhoneNumber (int index){
    return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.0,),
            TextFormField(
              controller: _phoneNumbersController[index],
              style: TextStyle(
                color: Colors.grey[600],
              ),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  hintText: 'Enter phone number ${index + 1} here',
                  hintStyle: TextStyle(
                      color: Colors.grey[600]
                  )
              ),
            ),
          ],
        )
    );
  }

  Future<DataModel?> createUser(String firstName, String lastName, List<dynamic> phoneNumbers) async {
    final response = await http.post(Uri.http('10.0.2.2:8000', 'phonebook'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic>{
          "first_name": firstName,
          "last_name": lastName,
          "phone_numbers": phoneNumbers,
        })
    );

    if (response.statusCode == 201){
      final String responseString = response.body;
      return dataModelFromJson(responseString);
    }
  }
}
