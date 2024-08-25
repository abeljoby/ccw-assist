import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class CreateClassroom extends StatefulWidget {
  const CreateClassroom({super.key});
  @override
  CreateClassroomState createState() => CreateClassroomState();
}

class CreateClassroomState extends State<CreateClassroom> {
  String? Department;
  String? ClassName;
  String? classroomCode;

  FirebaseFirestore db = FirebaseFirestore.instance;

  late String? name = '';
  late String? ktuID = '';
  
  @override
  void initState() {
    loadUserDetails();
    super.initState();
  }

  void loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name");
      ktuID = prefs.getString("ktuID");
    });
  }

  final _formKey = GlobalKey<FormState>();

  final departments = {'CSE':'Computer Science and Engineering', 'ECE':'Electronics and Communications Engineering','EEE':'Electrical and Electronics Engineering', 'ME':'Mechanical Engineering', 'CE':'Civil Engineering'};

  String generateCode(int length) {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create classroom', style: TextStyle(color: Colors.yellow,)),
        iconTheme: const IconThemeData(
          color: Colors.yellow, //change your color here
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const Image(image: AssetImage("images/classroom.jpg")),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Text("Give your classroom a name and select the department"),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a classroom name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        ClassName = value;
                      });
                    },
                  ),
                  const SizedBox(height:20),
                  DropdownButtonFormField<String>(
                    validator: (value) {
                      if (value == null || value.isEmpty || value == 'Select') {
                        return 'Please select a department';
                      }
                      return null;
                    },
                    hint: const Text("Select"),
                    value: Department,
                    items: departments.keys
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        Department = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height:20),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          classroomCode = generateCode(6);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Classroom created.')),
                          );
                          final classroom = <String, dynamic>{
                            "Name": ClassName,
                            "Department": Department,
                            "Code": classroomCode,
                            "Teacher": {"Name":name,"ktuID":ktuID},
                            "Students": [],
                          };
                          db.collection("classrooms").doc(classroomCode).set(classroom);
                          Navigator.pop(context);
                          Future.delayed(Duration.zero, () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Classroom created'),
                                  content: Text('You have created a classroom\nCode: $classroomCode'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 50),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
