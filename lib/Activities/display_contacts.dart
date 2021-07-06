import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phonebook_app/Activities/add_multiple_phone_number.dart';
import 'package:phonebook_app/person.dart';
import 'package:http/http.dart' as http;


class PhonebookDisplay extends StatefulWidget {

  @override
  _PhonebookDisplayState createState() => _PhonebookDisplayState();
}

class _PhonebookDisplayState extends State<PhonebookDisplay> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Phonebook'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0.0,
      ),
        body: Container(
            child: Card(
            child: FutureBuilder(
              future: getPhonebook(),
              builder: (context, AsyncSnapshot<dynamic> snapshot){
                if (snapshot.data == null){
                  return Container(
                    child: Center(
                      child: Text('Loading...'),
                    ),
                  );
                } else
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, i){
                        return ListTile(
                          title: Text(snapshot.data[i].firstName + ' ' + snapshot.data[i].lastName),
                          subtitle: Text(snapshot.data[i].phoneNumbers.toString()),
                        );
                      });
              },
            ),
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPhonebook()));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future getPhonebook() async{
    var response = await http.get(Uri.http('10.0.2.2:8000', 'phonebook'));
    var jsonData = jsonDecode(response.body);
    List<Person> persons = [];

    for (var u in jsonData){
      Person person = Person(u["first_name"], u["last_name"], u["phone_numbers"]);
      persons.add(person);
    }
    print(persons.length);
    return persons;
  }
}
