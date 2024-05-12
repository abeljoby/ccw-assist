import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final ktuid = TextEditingController();
  final email = TextEditingController();
  final acdyr = TextEditingController();
  final userid = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();

  FirebaseFirestore db = FirebaseFirestore.instance;

  final years = ['2023-24', '2024-25', '2025-26', '2026-27', '2027-28'];
  String? selectedyear;
  bool isStudent = true; // Initially set to student registration
  Color StudentColorButton = Colors.black;
  Color TeacherColorButton = Colors.white;
  Color StudentTextButton = Colors.white;
  Color TeacherTextButton = Colors.purple;
  void clrchg() {
    setState(() {
      if (isStudent == true) {
        StudentColorButton = Colors.black;
        TeacherColorButton = Colors.white;

        StudentTextButton = Colors.white;
        TeacherTextButton = Colors.purple;
      } else {
        StudentColorButton = Colors.white;
        TeacherColorButton = Colors.black;

        StudentTextButton = Colors.purple;
        TeacherTextButton = Colors.white;
      }
      name.clear();
      ktuid.clear();
      email.clear();
      acdyr.clear();
      userid.clear();
      password.clear();
      confirmpassword.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CCW ASSIST Registration'),
          centerTitle: true,
          backgroundColor: Colors.amber,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isStudent = true;
                      clrchg();
                      //  StudentColorButton = Colors.black;
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(StudentColorButton),
                      foregroundColor:
                          MaterialStateProperty.all(StudentTextButton)),
                  child: const Text(
                    'Student',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isStudent = false;
                      clrchg();
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(TeacherColorButton),
                    foregroundColor: MaterialStateProperty.all(TeacherTextButton),
                  ),
                  child: const Text(
                    'Teacher',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),
                if (isStudent) 
                  buildStudentFields() 
                else 
                  buildTeacherFields(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStudentFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Name of student'),
          ),
          TextFormField(
            controller: ktuid,
            decoration: const InputDecoration(labelText: 'KTU ID'),
          ),
          DropdownButtonFormField(
            decoration: const InputDecoration(
              labelText: "Academic Year",
            ),
            borderRadius: BorderRadius.circular(20.0),
            items: years
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              selectedyear = val;
            },
          ),
          TextFormField(
            controller: email,
            decoration: const InputDecoration(labelText: 'Email-ID'),
          ),
          TextFormField(
            controller: userid,
            decoration: const InputDecoration(labelText: 'User ID'),
          ),
          TextFormField(
            controller: password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextFormField(
            controller: confirmpassword,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                _register(context,email.text,password.text);
                // Handle student registration logic
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(200, 50),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTeacherFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Name of teacher'),
          ),
          TextFormField(
            controller: ktuid,
            decoration: const InputDecoration(labelText: 'KTU ID'),
          ),
          TextFormField(
            controller: email,
            decoration: const InputDecoration(labelText: 'Email-ID'),
          ),
          TextFormField(
            controller: userid,
            decoration: const InputDecoration(labelText: 'User name'),
          ),
          TextFormField(
            controller: password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextFormField(
            controller: confirmpassword,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
                onPressed: () {
                  _register(context,email.text,password.text);
                  // Handle teacher registration logic
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 20),
                )),
          ),
        ],
      ),
    );
  }

  void _register(BuildContext context, String mail, String pass) async {
    if (_formKey.currentState!.validate()) {
      try {
        final cred = await _auth.createUserWithEmailAndPassword(email: mail,password: pass);
        final user = <String, dynamic>{
          "batch": isStudent?acdyr.text:"",
          "dept": "Computer Science and Engineering",
          "email": email.text,
          "ktuID": ktuid.text,
          "name": name.text,
          "uid": cred.user?.uid,
          "userType": isStudent?"Student":"Teacher"
        };
        db.collection("users").add(user).then((DocumentReference doc) => print('DocumentSnapshot added with ID: ${doc.id}'));
        Navigator.pushNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }
}