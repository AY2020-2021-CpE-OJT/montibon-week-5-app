// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';


DataModel dataModelFromJson(String str) => DataModel.fromJson(json.decode(str));

String dataModelToJson(DataModel data) => json.encode(data.toJson());

class DataModel {
  DataModel({
    required this.phoneNumbers,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.v,
  });

  List<dynamic> phoneNumbers;
  String id;
  String firstName;
  String lastName;
  int v;

  factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
    phoneNumbers: List<String>.from(json["phone_numbers"].map((x) => x)),
    id: json["_id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "phone_numbers": List<dynamic>.from(phoneNumbers.map((x) => x)),
    "_id": id,
    "first_name": firstName,
    "last_name": lastName,
    "__v": v,
  };
}
