import 'dart:convert';
import 'package:dbms/pages/admin_page.dart';
import 'package:dbms/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: LoginPage(),
      initialRoute: '/',
      routes: {
        '/' : (context) => AdminPage()
      },
    );
  }
}

