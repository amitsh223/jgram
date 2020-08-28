import 'package:flutter/material.dart';
import 'package:jgram/widgets/Header.dart';
import 'package:jgram/widgets/ProgressWidget.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(context) {
    return Scaffold(appBar: header(context, appTitle: true),body: circularProgress(),);
  }
}
