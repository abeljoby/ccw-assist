import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:ccwassist/screens/scheduledtests.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StudentResult extends StatefulWidget {
  final Map<String,dynamic> data;
  final String testid;
  final String ktuid;
  const StudentResult({super.key, required this.data, required this.testid, required this.ktuid});

  @override
  State<StudentResult> createState() => _StudentResultState();
}

class _StudentResultState extends State<StudentResult> {
  late List<Map<String,dynamic>> questions = [];
  late String testID = "";
  late List<String> answers = [];
  late List<int> result = [];

  late Map<String,dynamic> dataCopy = {};
  late String? name = '';
  late String? ktuID = '';

  Future<void> fetchData() async {
    final questionSnapshot = await FirebaseFirestore.instance.collection("tests").doc(testID).collection("question-paper").orderBy("qno").get();
    final resultSnapshot = await FirebaseFirestore.instance.collection("tests").doc(testID).collection("results").doc(ktuID).get();

    questions = questionSnapshot.docs.map((q) => q.data()).toList(); 
    answers = resultSnapshot['answers'];
    result = resultSnapshot['result'];

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ktuID = widget.ktuid;
    testID = widget.testid;
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result', style: TextStyle(color: Colors.yellow)),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.yellow, //change your color here
        ),
        backgroundColor: Colors.black,
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
                Text('Date: ${dataCopy["StartDate"]} ${dataCopy["StartTime"]}\nName: $name\nCourse: ${dataCopy["Course"]}\nModules: ${dataCopy["Modules"].toString().substring(1, dataCopy['Modules'].toString().length - 1)}\nResult: ${result[0]}/${result[1]+result[2]+result[3]+result[4]}',textAlign:TextAlign.center,style: TextStyle(color: Colors.black,)),                // Add more details as needed
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: questions.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String,dynamic> ques = questions.elementAt(index);
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${index + 1}. ${ques['Question']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("1. ${ques['Option1']}"),
                      Text("2. ${ques['Option2']}"),
                      Text("3. ${ques['Option3']}"),
                      Text("4. ${ques['Option4']}"),
                      Text("Module: ${ques['Module']}"),
                      const SizedBox(height: 8),
                      if(ques['CorrectOption'] == answers[ques['qno']-1]) ...[
                      Text("Answered Option: ${answers[ques['qno']-1].substring(6)}",style: TextStyle(color: Colors.green))
                      ] else if(answers[ques['qno']-1] == '' || answers[ques['qno']-1] == 'R' || answers[ques['qno']-1] == 'NV') ... [
                      Text("Did not answer",style: TextStyle(color: Colors.red)),
                      ] else ... [
                      Text("Answered Option: ${answers[ques['qno']-1].substring(6)}",style: TextStyle(color: Colors.red)),
                      ],
                      Text("Correct Option: ${ques['CorrectOption'].substring(6)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Divider(), // Add a divider
                    ],
                  ),
                );
              }
            )
          ),
        ]
      )
    );
  }
}