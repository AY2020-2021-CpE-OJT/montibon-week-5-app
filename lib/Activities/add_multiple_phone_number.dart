import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:phonebook_app/main.dart';
import '../DataModel.dart';


class AddPhonebook extends StatefulWidget {

  @override
  _AddPhonebookState createState() => _AddPhonebookState();
}

class _AddPhonebookState extends State<AddPhonebook> {

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  List<TextEditingController> _phoneNumbersController = <TextEditingController>[];

  late DataModel? _user;

  int counter = 1;

  @override
  void initState(){
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Add Contact'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0.0,
      ),

      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(30),
              ),
              margin: EdgeInsets.all(10),
              child: TextFormField(
                autofocus: true,
                controller: _firstNameController,
                style: TextStyle(
                  color: Colors.white
                ),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                    isDense: true,
                    prefixIcon: Icon(Icons.person,
                      color: Colors.white,
                    ),
                    focusColor: Colors.white,
                    contentPadding: EdgeInsets.all(15),
                    hintText: 'First Name',
                    hintStyle: TextStyle(
                        color: Colors.grey[500]
                    )
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(30),
              ),
              margin: EdgeInsets.all(10),
              child: TextFormField(
                autofocus: true,
                controller: _lastNameController,
                style: TextStyle(
                    color: Colors.white
                ),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                    isDense: true,
                    prefixIcon: Icon(Icons.person,
                      color: Colors.white,
                    ),
                    focusColor: Colors.white,
                    contentPadding: EdgeInsets.all(15),
                    hintText: 'Last Name',
                    hintStyle: TextStyle(
                        color: Colors.grey[500]
                    )
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            Flexible(child: ListView.builder(
                itemCount: counter,
                itemBuilder: (context , index){
                  _phoneNumbersController.add(TextEditingController());
                  return dynamicPhoneNumber(index);
                },),
            ),
            Row(
              children: <Widget>[
                Wrap(
                  spacing: 140,
                  children: <Widget>[
                    TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                        ),
                        onPressed: (){
                          setState(() {
                            counter++;
                          });
                        },
                        child: Text('Add Phone Number',
                        style: TextStyle(
                          fontSize: 20,
                        ),)),
                    TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                        ),
                        onPressed: () async {
                          if (_firstNameController.text == '' || _lastNameController.text == ''){
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                                content: Container(
                                  color: Colors.red,
                                  height: 40,
                                  child: Center(
                                    child: Text('Invalid Input, Contact cannot be saved',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),),
                                  ),
                                ));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                          else {
                            final waitSnackbar = SnackBar(
                                content: Container(
                                  color: Colors.blue,
                                  height: 40,
                                  child: Center(
                                    child: Text('Updating Database',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(waitSnackbar);
                            List <dynamic> phoneNumbers = [];
                            String firstName = _firstNameController.text;
                            String lastName = _lastNameController.text;
                            _firstNameController.clear();
                            _lastNameController.clear();

                            for (int i = 0; i < counter; i++) {
                              if (_phoneNumbersController[i].text == ''){
                                _phoneNumbersController.remove(_phoneNumbersController[i]);
                                if (_phoneNumbersController[i].text != ''){
                                  phoneNumbers.add(_phoneNumbersController[i].text);
                                }
                              }
                              else {
                                phoneNumbers.add(_phoneNumbersController[i].text);
                              }
                            }
                            final DataModel? user = await createUser(firstName, lastName, phoneNumbers);
                            setState(() {
                              _user = user;
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                            });
                          }
                        },
                        child: Text('Save Contact',
                          style: TextStyle(
                            fontSize: 20,
                          ),)),
                  ],
                )
              ]
            ),
          ],
        ),
      ),
    );
  }

  dynamicPhoneNumber (int index){
    if (counter > 1){
      return Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(30),
          ),
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                autofocus: true,
                style: TextStyle(
                  color: Colors.white,
                ),
                controller: _phoneNumbersController[index],
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                    isDense: true,
                    prefixIcon: Icon(Icons.phone,
                      color: Colors.white,
                    ),
                    suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          _phoneNumbersController.remove(_phoneNumbersController[index]);
                          counter--;
                        });
                      },
                      icon: Icon(Icons.remove, color: Colors.redAccent[400]),

                    ),
                    contentPadding: EdgeInsets.all(15),
                    hintText: 'Phone Number ${index + 1}',
                    hintStyle: TextStyle(
                        color: Colors.grey[500]
                    )
                ),
                textInputAction: TextInputAction.next,
              ),
            ],
          )
      );
    }

    else {
      return Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(30),
          ),
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _phoneNumbersController[index],
                decoration: InputDecoration(
                    helperStyle: TextStyle(
                        color: Colors.white
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                    isDense: true,
                    prefixIcon: Icon(Icons.phone,
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.all(15),
                    hintText: 'Phone Number ${index + 1}',
                    hintStyle: TextStyle(
                        color: Colors.grey[500]
                    )
                ),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          )
      );
    }

  }

  Future<DataModel?> createUser(String firstName, String lastName, List<dynamic> phoneNumbers) async {
    final response = await http.post(Uri.https('phonebookapimontibon.herokuapp.com', 'phonebook'),
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

  Widget alertDialog(){
    return AlertDialog(
      titlePadding: EdgeInsets.all(10),
      title: Center(
        child: Text('Updating Database',
          style: TextStyle(
            color: Colors.grey[100],
          ),),
      ),
      content: Center(
        widthFactor: 1,
        heightFactor: 0,
        child: CircularProgressIndicator(),
      )
    );
  }
}
