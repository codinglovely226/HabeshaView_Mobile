import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:next_hour/loading/loading_screen.dart';

void main() {
    runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'habeshaview',
          home: LoadingScreen(),
          theme: new ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blue[800],
            accentColor: Color.fromRGBO(125, 183, 91, 1.0),
          ),
        )
    );
  }


