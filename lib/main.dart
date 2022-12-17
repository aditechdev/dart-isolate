import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

@immutable
class Person {
  final String name;
  final int age;
  const Person({required this.name, required this.age});

  Person.fromJson(Map<String, dynamic> json)
      : name = json["name"] as String,
        age = json["age"] as int;
}

// Interence Function
Future<Iterable<Person>> getPerson() async {
  final rp = ReceivePort(); // read and write tunnel
  await Isolate.spawn(_getPerson, rp.sendPort);
  return await rp.first;
}

void _getPerson(SendPort sp) async {
  const url = "http://127.0.0.1:5500/apis/people1.json";
  final persons = await HttpClient()
      .getUrl(Uri.parse(url))
      .then((req) => req.close())
      .then((response) => response.transform(utf8.decoder).join())
      .then((jsonString) => json.decode(jsonString) as List<dynamic>)
      .then((json) => json.map((e) => Person.fromJson(e)));

  Isolate.exit(sp, persons);
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            final person = await getPerson();
            person.log();
          },
          child: const Text(
            "Press Me",
          ),
        ),
      ),
    );
  }
}
