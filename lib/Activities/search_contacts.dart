import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:phonebook_app/main.dart';
import '../DataModel.dart';

class SearchContacts extends StatefulWidget {
  const SearchContacts({Key? key}) : super(key: key);

  @override
  _SearchContactsState createState() => _SearchContactsState();
}

class _SearchContactsState extends State<SearchContacts> {

  TextEditingController _search = TextEditingController();
  late Future futurePhonebook = getPhonebook();

  @override
  void initState(){
    super.initState();
    _search.addListener(() {
      filterContacts();
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0.0,
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
                children: [
                  Container(
                    width: 440,
                    child: TextFormField(
                      autofocus: true,
                      controller: _search,
                      style: TextStyle(
                          color: Colors.white,
                        fontSize: 17
                      ),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                          ),
                          isDense: true,
                          focusColor: Colors.white,
                          contentPadding: EdgeInsets.all(15),
                          hintText: 'Search Contact',
                          hintStyle: TextStyle(
                              color: Colors.grey[500]
                          )
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  TextButton(onPressed: (){}, child: Icon(
                    Icons.search,
                    color: Colors.white,
                  ))
                ],
              ),
          ],
        ),
      ),
    );
  }

  filterContacts(){
    if (_search.text.isNotEmpty) {
      String searchTerm = _search.text.toLowerCase();
    }
    else {
    }
  }


  Future getPhonebook() async{
    // final response = await http.get(Uri.http('10.0.2.2:3000', 'phonebook'));
    final response = await http.get(Uri.https('phonebookapimontibon.herokuapp.com', 'phonebook/showphonebook'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJ1c2VybmFtZSI6IkdlcmFsZCIsImVtYWlsIjoiZ2VyYWxkQGdtYWlsLmNvbSJ9LCJpYXQiOjE2MjY1MTA5MTF9.1kYutYVfFOwqnW4J9nQpiIOxdb2BsF0NljZSUlJa8mE'
        });

    final jsonData = jsonDecode(response.body);
    List<DataModel> dataModels = [];

    for (var u in jsonData){
      DataModel dataModel = DataModel(phoneNumbers: u["phone_numbers"], id: u["_id"], firstName: u["first_name"], lastName: u["last_name"], v: u["__v"]);
      dataModels.add(dataModel);
    }

    if (response.statusCode == 200){
      print(dataModels.length);
      return dataModels;
    }
  }

}
