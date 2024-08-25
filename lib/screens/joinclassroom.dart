import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinClassroom extends StatefulWidget {
  const JoinClassroom({super.key});
  @override
  JoinClassroomState createState() => JoinClassroomState();
}

class JoinClassroomState extends State<JoinClassroom> {
  final _formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a classroom', style: TextStyle(color: Colors.yellow,)),
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
                        return 'Please enter the classroom code';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Classroom Code',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        classroomCode = value;
                      });
                    },
                  ),
                  const SizedBox(height:20),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          var collectionRef = db.collection('classrooms');
                          var classroom = await collectionRef.doc(classroomCode).get();
                          if(classroom.exists) {
                            var classData = classroom.data();
                            final student = <String, dynamic>{
                              "Name": name,
                              "ktuID": ktuID,
                            };
                            db.collection("classrooms").doc(classroomCode).update({"Students": FieldValue.arrayUnion([student])});
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Classroom joined.')),
                            );
                            Navigator.pop(context);
                            Future.delayed(Duration.zero, () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Classroom joined'),
                                    content: Text('You have joined the classroom ${classData?['Name']} hosted by ${classData?['Teacher']['Name']}.'),
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
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('The code you entered is not valid.')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 50),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Join',
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
