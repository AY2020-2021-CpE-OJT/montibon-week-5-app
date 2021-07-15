import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonebook_app/Activities/add_multiple_phone_number.dart';
import 'package:http/http.dart' as http;
import 'package:phonebook_app/Activities/update_information.dart';
import 'package:phonebook_app/DataModel.dart';
import 'dart:async';

class PhonebookDisplay extends StatefulWidget {

  @override
  _PhonebookDisplayState createState() => _PhonebookDisplayState();
}

class _PhonebookDisplayState extends State<PhonebookDisplay> {

  late Future futurePhonebook = getPhonebook();
  int checker = 0;

  @override
  void initState(){
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Phonebook',
        style: TextStyle(
            color: Colors.white
        ),),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0.0,
      ),
        body: Container(
            child: FutureBuilder(
              future: futurePhonebook,
              builder: (context, AsyncSnapshot<dynamic> snapshot){
                if (snapshot.connectionState == ConnectionState.done){
                  if (snapshot.hasError){
                    return Container(
                      child: Center(
                        child: Text(
                            'No Contacts Found',
                        style: TextStyle(
                          color: Colors.white
                        ),),
                      ),
                    );
                  } else if (snapshot.hasData){
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index){
                          return Card(
                            margin: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)
                            ),
                            color: Colors.grey[850],
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                radius: 25,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey[850],
                                  radius: 23,
                                  child: Text(
                                    snapshot.data[index].firstName[0] + snapshot.data[index].lastName[0],
                                    style: TextStyle(
                                        letterSpacing: 3,
                                        color: Colors.grey[400]
                                    ),),
                                ),
                              ),
                                title: Text(snapshot.data[index].firstName + ' ' + snapshot.data[index].lastName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25
                                  ),),
                                //dense: true,
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                          numbersList(snapshot, index),
                                        ],
                                      ),
                                trailing: Wrap(
                                  spacing: 15,
                                  children: <Widget>[
                                    Container(
                                      height: 50,
                                      width: 50,
                                      child: FittedBox(
                                        child: FloatingActionButton(
                                          heroTag: null,
                                          backgroundColor:  Colors.grey[850],
                                          shape: StadiumBorder(
                                              side: BorderSide(
                                                  color: Colors.grey, width: 1
                                              )
                                          ),
                                          onPressed: () {
                                            String sendId = snapshot.data[index].id;
                                            print('id to be sent is: ' + snapshot.data[index].id);
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdateContact(receivedId: sendId)));
                                            setState(() {
                                            });
                                          },
                                          child: Icon(
                                              Icons.edit,
                                              color: Colors.grey[400]
                                          ),)
                                      ),
                                    ),
                                    Container(
                                      height: 50,
                                      width: 50,
                                      child: FittedBox(
                                        child: FloatingActionButton(
                                          heroTag: null,
                                          backgroundColor: Colors.grey[850],
                                          shape: StadiumBorder(
                                              side: BorderSide(
                                                  color: Colors.grey, width: 1
                                              )
                                          ),
                                          onPressed: () {
                                            print('Hello em here nao');
                                             showDialog(context: context, builder: (context) => deleteAlertDialog(snapshot, index));
                                          },
                                          child: Icon(
                                              Icons.delete,
                                              color: Colors.grey[400]
                                          ),)
                                      ),
                                    ),
                                  ],
                                ),
                            ),
                          );
                        });
                  }
                }
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
              },
            ),
        ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: Colors.grey[850],
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
    final response = await http.get(Uri.https('phonebookapimontibon.herokuapp.com', 'phonebook'));
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

  Future <DataModel?> deleteUser(String id) async {
    final response = await http.delete(Uri.https('phonebookapimontibon.herokuapp.com', 'phonebook/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
    );

    if (response.statusCode == 200){
      final String responseString = response.body;
      return dataModelFromJson(responseString);
    }
  }

  Widget numbersList(AsyncSnapshot<dynamic> snapshot, int index){
    return new Container(
      child: Column(
        children: snapshot.data[index].phoneNumbers.map<Widget>((x) => Text(
          x,
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 3,
              fontWeight: FontWeight.w500,
          ),)).toList(),
      ),
    );
  }

  Widget deleteAlertDialog(AsyncSnapshot<dynamic> snapshot, int index){
    return AlertDialog(
      titlePadding: EdgeInsets.all(10),
      title: Center(
        child: Text('Delete ' + snapshot.data[index].firstName + ' ' + snapshot.data[index].lastName,
          style: TextStyle(
            color: Colors.grey[100],
          ),),
      ),
      content: Center(
        widthFactor: 1,
        heightFactor: 0,
        child: Text('Confirm Deletion?',
          style: TextStyle(
            color: Colors.grey[100],
          ),),
      ),
      actions: [
        Row(
          children: <Widget>[
            Wrap(
              children: <Widget>[
                Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.green[800],
                  ),
                  child: TextButton(onPressed: (){
                    setState(() {
                      futurePhonebook = deleteUser(snapshot.data[index]!.id.toString());
                      print('Deleted ' + snapshot.data[index]!.id + ' Belonging to: ' + snapshot.data[index]!.firstName + ' ' + snapshot.data[index]!.lastName );
                      futurePhonebook = getPhonebook();
                      Navigator.of(context, rootNavigator: true).pop();
                    });
                  },
                      child: const Text('Confirm',
                      style: TextStyle(
                        color: Colors.white
                      ),)),
                ),
                Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.red[800],
                  ),
                  child: TextButton(onPressed: () {
                    setState(() {
                      print('set futurePhonebook to getPhonebook');
                      Navigator.of(context, rootNavigator: true).pop();
                    });
                    },
                      child: Text('Cancel',
                      style: TextStyle(
                        color: Colors.white
                      ),)),
                )
              ],
            ),

          ],
        ),
      ],
      elevation: 24,
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
    );
  }
}