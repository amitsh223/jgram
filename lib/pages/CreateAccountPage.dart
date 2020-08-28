import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jgram/widgets/Header.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  String userName;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  submitUserName() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackBar = SnackBar(
        content: Text('Welcome' + userName),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(
        Duration(seconds: 3),(){
        Navigator.pop(context,userName);
        });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, title: 'Create Account'),
      body: ListView(children: [
        Column(
          children: [
            Text(
              'Enter UserName',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            Container(
              height: 100,
              width: 400,
              padding: EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                autovalidate: true,
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  validator: (val) {
                    if (val.trim().length < 5 || val.isEmpty)
                      return 'UserName is too short';
                    if (val.length > 15)
                      return 'UserName is too long';
                    else
                      return null;
                  },
                  onSaved: (val) {
                    userName = val;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'must be five characters',
                      // hintStyle: TextStyle(fontSize: 16),
                      labelText: 'Username',
                      labelStyle: TextStyle(fontSize: 16),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: submitUserName,
          child: Container(
            height: 35,
            width: 200,
            child: Center(
              child: Text(
                'Proceed',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: Colors.green),
          ),
        )
      ]),
    );
  }
}
