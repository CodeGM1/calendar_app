import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

const url = "randomproject-cc55c-default-rtdb.asia-southeast1.firebasedatabase.app";

class CalendarRest{

  static const group = 'calendartask';

  createData(DateTime date, String title, String task) async {

    final response = await http.post(
      Uri.https(url, '$group.json'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },

      body: jsonEncode(<String, dynamic>{
        'date': date.toUtc().millisecondsSinceEpoch,
        'title': title,
        'task': task,
      }),
    );

    if (response.statusCode == 200) {
      print('successfully posted!');
    } else {
      throw Exception('Failed to load album with code of ${response.statusCode}');
    }
  }

  Future<List<calendarData>> fetchData() async {
    final response = await http.get(Uri.https(url, '$group.json'));

    if (response.statusCode == 200) {

      /*print(jsonDecode(response.body));*/

      var decodeMap = await jsonDecode(response.body) as Map<String, dynamic>;

      List<calendarData> array = [];
      if  (decodeMap.isNotEmpty) {

        decodeMap.forEach((key, value) {
          array.add(calendarData(
              id: key,
              date: value['date'],
              title: value['title'],
              task: value['task']
          ));
        });
      }

      return array;
    } else {
      throw Exception('Failed to load album with code of ${response.statusCode}');
    }
  }

  updateData(String id, DateTime date, String title, String task, List upChanged) async {

    Map<String,dynamic> jsonData = {};

    if(upChanged.contains(1)){
      jsonData.addAll({'title':title});
    }
    if(upChanged.contains(2)){
      jsonData.addAll({'task':task});
    }
    if(upChanged.contains(3)){
      jsonData.addAll({'date':date.toUtc().millisecondsSinceEpoch});
    }

    print(jsonData);

    final http.Response response = await http.patch(
        Uri.https(url,'$group/$id.json'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData)
    );

    if (response.statusCode == 200) {
      print('Successfully updated!');
    } else {
      print(response.statusCode);
      throw Exception('Failed to update album.');
    }
  }

  deleteData(String id) async{
    final http.Response response = await http.delete(Uri.https(url,'$group/$id.json'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 200) {
      print('Successfully deleted!');
    } else {
      print(response.statusCode);
      throw Exception('Failed to update album.');
    }
  }

}

class calendarData {
  final String id;
  final int date;
  final String title;
  final String task;

  factory calendarData.fromJson(Map<String, dynamic> json) {
    return calendarData(
      id: json['id'],
      date: json['date'],
      title: json['title'],
      task: json['task'],
    );
  }

  calendarData({required this.id, required this.date, required this.title, required this.task});
}

class LoginRest{

  static const group = 'calendarlogin';

  createData(String userid, String username, String email, String password) async {

    final response = await http.post(
      Uri.https(url, '$group.json'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },

      body: jsonEncode(<String, dynamic>{
        'userid': userid,
        'username': username,
        'email': email,
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      print('successfully posted!');
    } else {
      throw Exception('Failed to load album with code of ${response.statusCode}');
    }
  }

  Future<List<calendarData>> fetchData() async {
    final response = await http.get(Uri.https(url, '$group.json'));

    if (response.statusCode == 200) {

      /*print(jsonDecode(response.body));*/

      var decodeMap = await jsonDecode(response.body) as Map<String, dynamic>;

      List<calendarData> array = [];
      if  (decodeMap.isNotEmpty) {

        decodeMap.forEach((key, value) {
          array.add(calendarData(
              id: key,
              date: value['date'],
              title: value['title'],
              task: value['task']
          ));
        });
      }

      return array;
    } else {
      throw Exception('Failed to load album with code of ${response.statusCode}');
    }
  }

  updateData(String id, DateTime date, String title, String task, List upChanged) async {

    Map<String,dynamic> jsonData = {};

    if(upChanged.contains(1)){
      jsonData.addAll({'title':title});
    }
    if(upChanged.contains(2)){
      jsonData.addAll({'task':task});
    }
    if(upChanged.contains(3)){
      jsonData.addAll({'date':date.toUtc().millisecondsSinceEpoch});
    }

    print(jsonData);

    final http.Response response = await http.patch(
        Uri.https(url,'$group/$id.json'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData)
    );

    if (response.statusCode == 200) {
      print('Successfully updated!');
    } else {
      print(response.statusCode);
      throw Exception('Failed to update album.');
    }
  }

  deleteData(String id) async{
    final http.Response response = await http.delete(Uri.https(url,'$group/$id.json'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 200) {
      print('Successfully deleted!');
    } else {
      print(response.statusCode);
      throw Exception('Failed to update album.');
    }
  }

}

class loginData {
  final String userid;
  final String username;
  final String email;
  final String password;

  factory loginData.fromJson(Map<String, dynamic> json) {
    return loginData(
      userid: json['userid'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
    );
  }

  loginData(
      {required this.userid, required this.username, required this.email, required this.password});
}

class QRRest{

  static const group = 'calendarQR';

  createData(String userid, String location, DateTime date) async {

    final response = await http.post(
      Uri.https(url, '$group.json'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },

      body: jsonEncode(<String, dynamic>{
        'userid': userid,
        'location': location,
        'date': date.toUtc().millisecondsSinceEpoch,
      }),
    );

    if (response.statusCode == 200) {
      print('successfully posted!');
    } else {
      throw Exception('Failed to load album with code of ${response.statusCode}');
    }
  }

  Future<List<calendarData>> fetchData() async {
    final response = await http.get(Uri.https(url, '$group.json'));

    if (response.statusCode == 200) {

      /*print(jsonDecode(response.body));*/

      var decodeMap = await jsonDecode(response.body) as Map<String, dynamic>;

      List<calendarData> array = [];
      if  (decodeMap.isNotEmpty) {

        decodeMap.forEach((key, value) {
          array.add(calendarData(
              id: key,
              date: value['date'],
              title: value['title'],
              task: value['task']
          ));
        });
      }

      return array;
    } else {
      throw Exception('Failed to load album with code of ${response.statusCode}');
    }
  }

  updateData(String id, DateTime date, String title, String task, List upChanged) async {

    Map<String,dynamic> jsonData = {};

    if(upChanged.contains(1)){
      jsonData.addAll({'title':title});
    }
    if(upChanged.contains(2)){
      jsonData.addAll({'task':task});
    }
    if(upChanged.contains(3)){
      jsonData.addAll({'date':date.toUtc().millisecondsSinceEpoch});
    }

    print(jsonData);

    final http.Response response = await http.patch(
        Uri.https(url,'$group/$id.json'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData)
    );

    if (response.statusCode == 200) {
      print('Successfully updated!');
    } else {
      print(response.statusCode);
      throw Exception('Failed to update album.');
    }
  }

  deleteData(String id) async{
    final http.Response response = await http.delete(Uri.https(url,'$group/$id.json'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 200) {
      print('Successfully deleted!');
    } else {
      print(response.statusCode);
      throw Exception('Failed to update album.');
    }
  }

}

class QRData {
  final String userid;
  final String location;
  final int date;

  factory QRData.fromJson(Map<String, dynamic> json) {
    return QRData(
      userid: json['userid'],
      location: json['location'],
      date: json['date'],
    );
  }

  QRData({required this.userid, required this.location, required this.date});
}

