import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phonebook_app/Activities/add_multiple_phone_number.dart';
import 'package:http/http.dart' as http;
import 'package:phonebook_app/Activities/update_information.dart';
import 'package:phonebook_app/DataModel.dart';
import 'dart:async';
import 'dart:io';
import '../main.dart';

class PhonebookDisplay2 extends StatefulWidget {

  @override
  _PhonebookDisplayState2 createState() => _PhonebookDisplayState2();
}

class _PhonebookDisplayState2 extends State<PhonebookDisplay2> {

  late Future futurePhonebook;
  int checker = 0;
  TextEditingController _search = TextEditingController();
  List<DataModel> contacts = [];
  List<DataModel> contactsFiltered = [];


  @override
  void initState(){
    super.initState();
    futurePhonebook = getPhonebook();
  }

  Future filterContacts() async{
    final response = await http.get(Uri.https('phonebookapimontibon.herokuapp.com', 'phonebook'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2MGY2ODhkOGVmZTNjNzRiOTAwMmQ4NDMiLCJpYXQiOjE2MjY3Njk2MzB9.rPXdeTVdIt_F3piPCZh9Zi6PwbcsLLuScDXpOt9uvRQ'
        });

    final jsonData = jsonDecode(response.body);
    List<DataModel> dataModels = [];

    for (var u in jsonData){
      DataModel dataModel = DataModel(phoneNumbers: u["phone_numbers"], id: u["_id"], firstName: u["first_name"], lastName: u["last_name"], v: u["__v"]);
      dataModels.add(dataModel);
    }

    if (response.statusCode == 200){
      print(dataModels.length);
      contacts.addAll(dataModels);
      if (_search.text.isNotEmpty){
        contacts.retainWhere((dataModel){
          String searchTerm = _search.text.toLowerCase();
          String contactTerm = dataModel.firstName.toLowerCase();
          return contactTerm.contains(searchTerm);
        });

        setState(() {
          contactsFiltered = contacts;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0.0,

        actions: <Widget>[
          Wrap(
            children: [
              TextButton(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPhonebook()));
                },
                child: Icon(Icons.add, color: Colors.white,),),
              Container(
                padding: EdgeInsets.all(12),
                child: PopupMenuButton(
                    color: Colors.grey[850],
                    child: Icon(Icons.more_vert, color: Colors.white,),
                    itemBuilder: (context){
                      return List.generate(1, (index) {
                        return PopupMenuItem(
                            child: Text('Delete contacts', style: TextStyle(color: Colors.white),)
                        );
                      });
                    }),
              )
            ],
          )
        ],

      ),
      body: Container(
        child: FutureBuilder(
          future: futurePhonebook = getPhonebook(),
          builder: (context, AsyncSnapshot<dynamic> snapshot){
            if (snapshot.connectionState == ConnectionState.done){
              if (snapshot.hasError){
                return Container(
                  child: Center(
                    child: Text('No Contacts Found', style: TextStyle(color: Colors.white),),
                  ),
                );
              } else if (snapshot.hasData){
                return Column(
                  children: <Widget>[
                    Container(
                      width: 510,
                      child: TextFormField(
                        controller: _search,
                        style: TextStyle(color: Colors.white, fontSize: 17),
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white,),
                              borderRadius: BorderRadius.circular(30),),
                            isDense: true,
                            focusColor: Colors.white,
                            prefixIcon: Icon(Icons.search, color: Colors.white,),
                            contentPadding: EdgeInsets.all(15),
                            hintText: 'Search Contact',
                            hintStyle: TextStyle(color: Colors.grey[500])
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index){
                              return InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: (){
                                  String sendId = snapshot.data[index].id;
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdateContact(receivedId: sendId)));
                              },
                                onLongPress: (){
                                  showDialog(context: context, builder: (context) => deleteAlertDialog(snapshot, index));
                                },
                              child: Card(
                                margin: EdgeInsets.all(8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                color: Colors.grey[850],
                                child: ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey[100],
                                    radius: 25,
                                    child: CircleAvatar(backgroundColor: Colors.grey[850], radius: 23,
                                      child: Text(snapshot.data[index].firstName[0] + snapshot.data[index].lastName[0],
                                        style: TextStyle(letterSpacing: 3, color: Colors.grey[400]),),
                                    ),
                                  ),
                                  title: Text(snapshot.data[index].firstName + ' ' + snapshot.data[index].lastName,
                                    style: TextStyle(color: Colors.white, fontSize: 25),),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      numbersList(snapshot, index),
                                    ],
                                  ),
                                  //Trailer
                                  //trailing:
                                  // Wrap(
                                  //   spacing: 15,
                                  //   children: <Widget>[
                                  //     Container(
                                  //       height: 50,
                                  //       width: 50,
                                  //       child: FittedBox(
                                  //           child: FloatingActionButton(
                                  //             heroTag: null,
                                  //             backgroundColor:  Colors.grey[850],
                                  //             shape: StadiumBorder(
                                  //                 side: BorderSide(
                                  //                     color: Colors.grey, width: 1
                                  //                 )
                                  //             ),
                                  //             onPressed: () {
                                  //               String sendId = snapshot.data[index].id;
                                  //               print('id to be sent is: ' + snapshot.data[index].id);
                                  //               Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdateContact(receivedId: sendId)));
                                  //             },
                                  //             child: Icon(
                                  //                 Icons.edit,
                                  //                 color: Colors.grey[400]
                                  //             ),)
                                  //       ),
                                  //     ),
                                  //     Container(
                                  //       height: 50,
                                  //       width: 50,
                                  //       child: FittedBox(
                                  //           child: FloatingActionButton(
                                  //             heroTag: null,
                                  //             backgroundColor: Colors.grey[850],
                                  //             shape: StadiumBorder(
                                  //                 side: BorderSide(
                                  //                     color: Colors.grey, width: 1
                                  //                 )
                                  //             ),
                                  //             onPressed: () {
                                  //               print('Hello em here nao');
                                  //               showDialog(context: context, builder: (context) => deleteAlertDialog(snapshot, index));
                                  //             },
                                  //             child: Icon(
                                  //                 Icons.delete,
                                  //                 color: Colors.grey[400]
                                  //             ),)
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ),
                              ),);
                            })
                    ),
                  ],
                );
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
    );
  }

  Future getPhonebook() async{
    // final response = await http.get(Uri.http('10.0.2.2:3000', 'phonebook'));
    final response = await http.get(Uri.https('phonebookapimontibon.herokuapp.com', 'phonebook'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2MGY2ODhkOGVmZTNjNzRiOTAwMmQ4NDMiLCJpYXQiOjE2MjY3Njk2MzB9.rPXdeTVdIt_F3piPCZh9Zi6PwbcsLLuScDXpOt9uvRQ'
        });

    final jsonData = jsonDecode(response.body);
    List<DataModel> dataModels = [];

    for (var u in jsonData){
      DataModel dataModel = DataModel(phoneNumbers: u["phone_numbers"], id: u["_id"], firstName: u["first_name"], lastName: u["last_name"], v: u["__v"]);
      dataModels.add(dataModel);
    }

    if (response.statusCode == 200){
      print(dataModels.length);
      dataModels.sort((a, b){
        return a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
      });
      return dataModels;
    }
  }

  Future <DataModel?> deleteUser(String id) async {
    // final response = await http.delete(Uri.https('10.0.2.2:3000', 'phonebook/$id'),

    final response = await http.delete(Uri.https('phonebookapimontibon.herokuapp.com', 'phonebook/delete/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2MGY2ODhkOGVmZTNjNzRiOTAwMmQ4NDMiLCJpYXQiOjE2MjY3Njk2MzB9.rPXdeTVdIt_F3piPCZh9Zi6PwbcsLLuScDXpOt9uvRQ'
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
        children: snapshot.data[index].phoneNumbers.map<Widget>((x) => Text(x, style: TextStyle(color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.w500,),)).toList(),),
    );
  }

  Widget deleteAlertDialog(AsyncSnapshot<dynamic> snapshot, int index){
    return AlertDialog(
      titlePadding: EdgeInsets.all(10),
      title: Center(
        child: Text('Delete ' + snapshot.data[index].firstName + ' ' + snapshot.data[index].lastName,
          style: TextStyle(color: Colors.grey[100],),),
      ),
      content: Center(
        widthFactor: 1,
        heightFactor: 0,
        child: Text('Confirm Deletion?', style: TextStyle(color: Colors.grey[100],),),
      ),
      actions: [
        Row(
          children: <Widget>[
            Wrap(
              children: <Widget>[
                Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.green[800],),
                  child: TextButton(onPressed: () async {
                    print('Deleted ' + snapshot.data[index]!.id + ' Belonging to: ' + snapshot.data[index]!.firstName + ' ' + snapshot.data[index]!.lastName );
                    setState(() {
                      futurePhonebook = deleteUser(snapshot.data[index]!.id.toString());
                      print('this is called');
                      futurePhonebook = getPhonebook();
                    });
                    Navigator.of(context, rootNavigator: true).pop();
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                  },
                      child: const Text('Confirm', style: TextStyle(color: Colors.white),)),
                ),
                Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.red[800],),
                  child: TextButton(onPressed: () {
                    print('set futurePhonebook to getPhonebook');
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                      child: Text('Cancel', style: TextStyle(color: Colors.white),)),)
              ],),],),],
      elevation: 24,
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

}