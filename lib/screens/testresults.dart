import 'package:ccwassist/screens/studentresult.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TestResults extends StatefulWidget {
  final Map<String,dynamic> data;
  final String testid;
  const TestResults({super.key, required this.data, required this.testid});

  @override
  State<TestResults> createState() => _TestResultsState();
}

class _TestResultsState extends State<TestResults> {
  late Map<String,dynamic> testData = {};
  late String testID = '';
  late Stream<QuerySnapshot<Map<String, dynamic>>> _userStream = FirebaseFirestore.instance.collection('tests').doc(testID).collection('results').snapshots();
  final courses = {'DMS':'Discrete Mathematical Structures', 'DS':'Data Structures','COA':'Computer Organization and Architecture', 'DBMS':'DataBase Management Systems', 'OS':'Operating Systems', 'FLAT':'Formal Languages and Automata Theory'};
  
  @override
  void initState() {
    super.initState();
    setState(() {
      testData = widget.data;
      testID = widget.testid;
      // _userStream = FirebaseFirestore.instance.collection('tests').doc(testID).collection('results').snapshots();
    });
  }

  Future<Map<String,dynamic>> fetchStudent(String ktuID) async {
    final studentSnapshot = await FirebaseFirestore.instance.collection("users").where("ktuID",isEqualTo: ktuID).limit(1).get();
    Map<String,dynamic> user = studentSnapshot.docs.elementAt(0).data();
    return user;
  }

  Widget _buildTestSection({
    required Map<String, dynamic> data,
    required String testid,
    required String ktuid
  }) {
    return FutureBuilder(
      future: fetchStudent(ktuid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (!snapshot.hasData) {
          return Center(child:SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
        }
        else {
          Map<String,dynamic>? student = snapshot.data;
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: ((context) => StudentResult(data: data,testid: testid,ktuid: ktuid,name: student!['name']))));
                }, // Handle your callback
                child: Ink(height: 40,child: Center(child: Text(student!['name'],style: TextStyle(fontWeight: FontWeight.bold))),color: Colors.white,),
              ),
              const Divider()
            ],
          );
        }
        
      },
    );
    // return Column(
    //   children: [
    //     // Container(
    //     //   padding: EdgeInsets.only(left: 16,right: 16,top: 5,bottom: 5),
    //     //   width: double.infinity,
    //     //   color: Colors.black,
    //     //   child: Text(ktuid, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
    //     // ),
    //     Container(
    //       padding: EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 16),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //             children: [
    //               ElevatedButton(
    //                 onPressed: () {
    //                   // Handle edit test action
    //                   Navigator.push(context,MaterialPageRoute(builder: ((context) => StudentResult(data: data,testid: testid,ktuid: ktuid,name: "Abel"))));
    //                 },
    //                 style: ElevatedButton.styleFrom(
    //                   backgroundColor: Colors.amber,
    //                   foregroundColor: Colors.black
    //                 ),
    //                 child: const Text('View Result'),
    //               ),
    //             ],
    //           ),
    //           // const Divider(), // Add a divider
    //         ],
    //       ),
    //     ),
    //     // SizedBox(height: 20,),
    //     Divider(),
    //   ],
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
        // centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.amber, //change your color here
        ),
        backgroundColor: Colors.black,
        //leading: IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back_sharp))
      ),
      body: Column(
        children: [
          Container(
            height: 135,
            width: double.infinity,
            decoration: const BoxDecoration(color:Color.fromARGB(255, 217, 217, 217),border: Border(bottom: BorderSide(color:Color.fromARGB(255,192,192,192),width: 5))),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Date: ${testData["StartDate"]}\nTime: ${testData["StartTime"]}\nDuration: ${testData["Duration"]}\nCourse: ${testData["Course"]}\nModules: ${testData["Modules"].toString().substring(1, testData['Modules'].toString().length - 1)}',textAlign:TextAlign.center,style: TextStyle(color: Colors.black,)),                // Add more details as needed
              ],
            ),
          ),
          const SizedBox(height: 5),
          StreamBuilder(
            stream: _userStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if (!snapshot.hasData) {
                return Center(child:SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
              }
              else if (snapshot.data?.size == 0) {
                return Center(child: Text("No students have attended the test yet.",));
              }
              else {
                return ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  // Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  return _buildTestSection(data: testData, ktuid: document.id, testid: testID);
                  }).toList(),
                );
                // return Divider();
              }
            }
          ),
        ],
      ) 
    );
  }
}