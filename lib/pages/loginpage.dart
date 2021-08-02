import 'package:calendar_app/api_manager/restful.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatelessWidget {

  TextEditingController ctrlUser = new TextEditingController();
  TextEditingController ctrlPw = new TextEditingController();

  final loginrest = LoginRest();

  void verificationLogin(){

    loginrest.fetchData();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF6200EE),
          title: Text(
            'Login',
            style: TextStyle(fontSize: 24),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
            ),
            Container(
              child: Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: SizedBox(
                    width: 380,
                    child: TextFormField(
                      controller: ctrlUser,
                      style: TextStyle(fontSize: 28),
                      cursorColor: Colors.blueGrey,
                      inputFormatters: [LengthLimitingTextInputFormatter(15)],
                      onChanged: (text) {},
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(fontSize: 24, color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.supervisor_account),
                      ),
                    ),
                  )),
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(width: 1, color: Colors.grey))),
            ),
            Container(
              child: Padding(
                  padding: EdgeInsets.only(top: 25, left: 25),
                  child: SizedBox(
                    width: 380,
                    child: TextFormField(
                      controller: ctrlPw,
                      style: TextStyle(fontSize: 24),
                      cursorColor: Colors.blueGrey,
                      inputFormatters: [LengthLimitingTextInputFormatter(128)],
                      onChanged: (text) {},
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                  )),
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(width: 1, color: Colors.grey))),
            ),
            SizedBox(
              height: 25,
            ),
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {},
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.grey))))),
            )
          ],
        ));
  }
}
