// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
class StudentClassroom extends StatefulWidget {
  const StudentClassroom({super.key});
  @override
  State<StudentClassroom> createState() => StudentClassroomState();
}

class StudentClassroomState extends State<StudentClassroom> {
  late Stream<QuerySnapshot> _classStream;

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
    _classStream = FirebaseFirestore.instance.collection('classrooms').where('Students',arrayContains: {'Name':name,'ktuID':ktuID}).snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classrooms', style: TextStyle(fontWeight: FontWeight.bold)),
        // centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _classStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (!snapshot.hasData) {
            return Center(child:SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
          }
          else if (snapshot.data?.size == 0) {
            return Center(child: Text("No classrooms joined.",));
          }
          else {
            return ListView(
              shrinkWrap: true,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> classData = document.data()! as Map<String, dynamic>;
              List<dynamic> studentData = classData['Students'];
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: ExpansionTile(
                    // expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    shape: const Border(),
                    initiallyExpanded: false,
                    title: Text("${classData['Name']}",style: TextStyle(fontWeight: FontWeight.bold),),
                    // trailing: InkWell(
                    //   child: Text("Classroom Code: ${classData['Code']}",style: TextStyle(fontWeight: FontWeight.bold)),
                    //   onTap: () {
                    //     Clipboard.setData(ClipboardData(text: "${classData['Code']}"))
                    //     .then((_) {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(content: Text('Classroom code copied to your clipboard.')));
                    //     });
                    //   },
                    // ),
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ListView(
                            shrinkWrap: true,
                            children: studentData.map((student) {
                              return Container(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${student['Name']} (${student['ktuID']})")
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        )
                      )
                    ]
                  )
                ),
              );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/joinclass');
        },
        // label: Text('Join classroom'),
        shape: const CircleBorder(),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
