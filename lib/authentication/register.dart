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
  final userid = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();
  final years = ['2023-24', '2024-25', '2025-26', '2026-27', '2027-28'];

  String? acdyr;

  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration', style: TextStyle(fontWeight: FontWeight.bold)),
        // centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              buildStudentFields()
            ],
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            controller: name,
            decoration: const InputDecoration(labelText: 'Name of student'),
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your KTU ID';
              }
              return null;
            },
            controller: ktuid,
            decoration: const InputDecoration(labelText: 'KTU ID'),
          ),
          // DropdownButton(
          //   decoration: const InputDecoration(
          //     labelText: "Academic Year",
          //   ),
          //   borderRadius: BorderRadius.circular(20.0),
          //   items: years
          //       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          //       .toList(),
          //   onChanged: (val) {
          //     acdyr.text = val;
          //   },
          // ),
          DropdownButtonFormField<String>(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a year';
              }
              return null;
            },
            // hint: const Text("Select"),
            value: acdyr,
            items: years
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
            onChanged: (String? newValue) {
              setState(() {
                acdyr = newValue;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Course',
              // border: OutlineInputBorder(),
            ),
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email ID';
              }
              return null;
            },
            controller: email,
            decoration: const InputDecoration(labelText: 'Email ID'),
          ),
          // TextFormField(
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please enter some text';
          //     }
          //     return null;
          //   },
          //   controller: userid,
          //   decoration: const InputDecoration(labelText: 'Username'),
          // ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
            controller: password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value != password.text) {
                return 'The passwords entered do not match';
              }
              return null;
            },
            controller: confirmpassword,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
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
            decoration: const InputDecoration(labelText: 'Email ID'),
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
      var studentSnapshot = await FirebaseFirestore.instance.collection("users").where("ktuID",isEqualTo: ktuid.text).get();
      if(studentSnapshot.docs.isEmpty) {
        try {
          final cred = await _auth.createUserWithEmailAndPassword(email: mail,password: pass);
          final user = <String, dynamic>{
            "batch": acdyr,
            "dept": "Computer Science and Engineering",
            "email": email.text,
            "ktuID": ktuid.text,
            "name": name.text,
            "uid": cred.user?.uid,
            "userType": "Student"
          };
          db.collection("users").add(user).then((DocumentReference doc) => print('DocumentSnapshot added with ID: ${doc.id}'));
          Navigator.pop(context);
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An account already exists with the same KTU ID."),
          ),
        );
      }
    }
  }
}