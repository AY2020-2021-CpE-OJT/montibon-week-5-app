import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phonebook_app/main.dart';
import '../DataModel.dart';


class UpdateContact extends StatefulWidget {
  final String receivedId;
  const UpdateContact({Key? key, required this.receivedId}) : super(key: key);

  @override
  _UpdateContactState createState() => _UpdateContactState();
}

class _UpdateContactState extends State<UpdateContact> {

  late Future<DataModel?> futureContact = getSpecificContact(widget.receivedId);
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  List<TextEditingController> _phoneNumbersController = [];
  late int counter;
  bool firstTime = true;
  bool fetchOrGet = true;
  bool noComment = true;
  int phoneNumberCounter = 0;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Contact',
          style: TextStyle(
            color: Colors.white,
          ),),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Card(
          color: Colors.black,
          child: FutureBuilder<DataModel?>(
            future: futureContact,
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Container(
                    child: Center(
                      child: Text('Error Occurred'),
                    ),
                  );
                } else if (snapshot.hasData) {
                  if (firstTime == true) {
                    counter = snapshot.data.phoneNumbers.length;
                    _firstNameController = TextEditingController(text: snapshot.data.firstName);
                    _lastNameController = TextEditingController(text: snapshot.data.lastName);
                    firstTime = false;
                  }
                  else {
                    print('Current phone number entry: ' + '$counter');
                  }
                  print(snapshot.data.phoneNumbers);
                  return Stack(
                    children: <Widget>[
                  Container(
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
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        margin: EdgeInsets.all(10),
                        child: TextFormField(
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
                        ),
                      ),
                      Flexible(child: ListView.builder(
                        itemCount: counter,
                        itemBuilder: (context, index) {
                          if (phoneNumberCounter < snapshot.data.phoneNumbers.length) {
                            for (int i = 0; i < snapshot.data.phoneNumbers.length; i++) {
                              _phoneNumbersController.add(TextEditingController(text: snapshot.data.phoneNumbers[phoneNumberCounter]));
                              phoneNumberCounter++;
                              return dynamicPhoneNumber(index);
                            }
                          }
                          else {
                            _phoneNumbersController.add(TextEditingController());
                            return dynamicPhoneNumber(index);
                          }
                          throw ('Error received');
                        },
                      ),
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
                                  onPressed: () {
                                    setState(() {
                                      counter++;
                                    });},
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
                                      noComment = false;

                                      List <dynamic> phoneNumbers = [];
                                      for (int i = 0; i < counter; i++) {
                                        if (_phoneNumbersController[i].text == ''){
                                          _phoneNumbersController.remove(_phoneNumbersController[i]);
                                          if (_phoneNumbersController[i].text != ''){
                                            phoneNumbers.add(_phoneNumbersController[i].text);
                                            _phoneNumbersController[i].clear();
                                          }
                                        }
                                        else {
                                          phoneNumbers.add(_phoneNumbersController[i].text);
                                        }
                                      }
                                      print('First Name: ' + _firstNameController.text + '\n'
                                          'Last Name: ' + _lastNameController.text + '\n' +
                                          'Phone Numbers: ');
                                      for (int i = 0; i < phoneNumbers.length; i++) {
                                        print(phoneNumbers[i] + '\n');
                                      }
                                      setState((){
                                        futureContact = updateContact(widget.receivedId, _firstNameController.text.toString(), _lastNameController.text.toString(), phoneNumbers);
                                        futureContact = getSpecificContact(widget.receivedId);
                                        _firstNameController.clear();
                                        _lastNameController.clear();
                                      });
                                      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                                    }
                                  },
                                  child: Text('Save Changes',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),)
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
              ),
                    ],
                  );
                }
              }
              if (fetchOrGet == true && noComment == true){
                fetchOrGet = false;
                return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                        SizedBox(height: 10,),
                        Center(
                          child: Text('Fetching Data from Database',
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        ),
                      ],
                    )
                );
              }
              else if (fetchOrGet == false && noComment == true){
                return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                        SizedBox(height: 10,),
                        Center(
                          child: Text('Updating Database',
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        ),
                      ],
                    )
                );
              }
              else {
                return  Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<DataModel?> getSpecificContact(String id) async {
    final response = await http.get(
        Uri.https('phonebookapimontibon.herokuapp.com', 'phonebook/$id'));

    if (response.statusCode == 200) {
      print('Successfully got data');
      return dataModelFromJson(response.body);
    }
  }

  Future<DataModel?> updateContact(String id, String firstName, String lastName,
      List<dynamic> phoneNumbers) async {
    final response = await http.patch(
        Uri.https('phonebookapimontibon.herokuapp.com', 'phonebook/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic>{
          "first_name": firstName,
          "last_name": lastName,
          "phone_numbers": phoneNumbers,
        })
    );

    if (response.statusCode == 201) {
      final String responseString = response.body;
      return dataModelFromJson(responseString);
    }
  }

  dynamicPhoneNumber(int index) {
    if (counter > 1) {
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
                      onPressed: () {
                         setState(() {
                           _phoneNumbersController.remove(_phoneNumbersController[index]);
                           counter--;
                         });
                      }
                      ,
                      icon: Icon(Icons.remove, color: Colors.redAccent[400]),

                    ),
                    contentPadding: EdgeInsets.all(15),
                    hintText: 'Phone Number ${index + 1}',
                    hintStyle: TextStyle(
                        color: Colors.grey[500]
                    )
                ),
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
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _phoneNumbersController[index].clear();
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
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          )
      );
    }
  }
}