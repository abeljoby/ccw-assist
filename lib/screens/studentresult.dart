import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:ccwassist/screens/scheduledtests.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPaper {
  List<Map<String,dynamic>> questions;
  List<dynamic> answers;
  List<dynamic> result;
  ResultPaper(this.questions,this.answers,this.result);
}

class StudentResult extends StatefulWidget {
  final Map<String,dynamic> data;
  final String testid;
  final String ktuid;
  final String name;
  const StudentResult({super.key, required this.data, required this.testid, required this.ktuid,required this.name});

  @override
  State<StudentResult> createState() => _StudentResultState();
}

class _StudentResultState extends State<StudentResult> {
  late String testID = "";
  late Map<String,dynamic> testData = {};
  late String? name = '';
  late String? ktuID = '';

  Future<ResultPaper> fetchData() async {
    final questionSnapshot = await FirebaseFirestore.instance.collection("tests").doc(testID).collection("question-paper").orderBy("qno").get();
    final resultSnapshot = await FirebaseFirestore.instance.collection("tests").doc(testID).collection("results").doc(ktuID).get();

    List<Map<String,dynamic>> questions = questionSnapshot.docs.map((q) => q.data()).toList();
    List<dynamic> answers = resultSnapshot['Answers'];
    List<dynamic> result = resultSnapshot['Result'];

    return ResultPaper(questions, answers, result);
  }

  @override
  void initState() {
    super.initState();
    testID = widget.testid;
    testData = widget.data;
    ktuID = widget.ktuid;
    name = widget.name;
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result', style: TextStyle(color: Colors.amber)),
        // centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.amber, //change your color here
        ),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: fetchData(), 
        builder: (context,snapshot) {
          if (snapshot.hasData){
            ResultPaper rp = snapshot.data!;
            List<Map<String,dynamic>> questionPaper = rp.questions;
            List<dynamic> answers = rp.answers;
            List<dynamic> result = rp.result;
            return Column(
              children: [
                Container(
                  height: 135,
                  width: double.infinity,
                  decoration: const BoxDecoration(color:Color.fromARGB(255, 217, 217, 217),border: Border(bottom: BorderSide(color:Color.fromARGB(255,192,192,192),width: 5))),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Date: ${testData["StartDate"]} ${testData["StartTime"]}\nName: $name\nCourse: ${testData["Course"]}\nModules: ${testData["Modules"].toString().substring(1, testData['Modules'].toString().length - 1)}\nResult: ${result[0]}/${result[1]+result[2]+result[3]}',textAlign:TextAlign.center,style: TextStyle(color: Colors.black,)),                // Add more details as needed
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: questionPaper.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String,dynamic> ques = questionPaper.elementAt(index);
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
                  ),
                )
              ]
            );
          }
          else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          else {
            return Center(child:SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
          }
        }
      )
    );
  }
}