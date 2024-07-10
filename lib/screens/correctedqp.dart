import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:ccwassist/screens/scheduledtests.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CorrectedQuestionPaper extends StatefulWidget {
  final Map<String,dynamic> data;
  final String id;
  final List<String> ans;
  final List<int> res;
  const CorrectedQuestionPaper({super.key, required this.data, required this.id, required this.ans, required this.res});

  @override
  State<CorrectedQuestionPaper> createState() => _CorrectedQuestionPaperState();
}

class _CorrectedQuestionPaperState extends State<CorrectedQuestionPaper> {
  late Map<String,dynamic> dataCopy = {};
  late String testID = "";
  late List<String> answers = [];
  late List<int> result = [];

  late String? name = '';
  late String? batch = '';
  late String? ktuID = '';
  late String? email = '';
  late String? dept = '';

  void loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name");
      ktuID = prefs.getString("ktuID");
      email = prefs.getString("email");
      dept = prefs.getString("dept");
      batch = prefs.getString("batch");
    });
  }

  Future<List<Map<String,dynamic>>> getCorrectedQuestionPaper(testID) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = 
    await FirebaseFirestore.instance.collection("tests")
    .doc(testID)
    .collection("question-paper")
    .orderBy("qno")
    .get();
    List<Map<String,dynamic>> _questions = snapshot.docs.map((q) => q.data()).toList();
    return _questions;
  }

  @override
  void initState() {
    loadUserDetails();
    super.initState();
    dataCopy = widget.data;
    testID = widget.id;
    answers = widget.ans;
    result = widget.res;
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
                Text('Date: ${dataCopy["StartDate"]} ${dataCopy["StartTime"]}\nName: $name\nCourse: ${dataCopy["Course"]}\nModules: ${dataCopy["Modules"].toString().substring(1, dataCopy['Modules'].toString().length - 1)}\nResult: ${result[0]}/${result[1]+result[2]+result[3]}',textAlign:TextAlign.center,style: TextStyle(color: Colors.black,)),                // Add more details as needed
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getCorrectedQuestionPaper(testID),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var questionPaper = snapshot.data as List<Map<String,dynamic>>;
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: questionPaper.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String,dynamic> ques = questionPaper.elementAt(index);
                      // Create a container for each element
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
                            ] else if(answers[ques['qno']-1] == '' || answers[ques['qno']-1] == 'NV') ... [
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
                  );
                }
                // while waiting for data to arrive, show a spinning indicator
                return Center(child:SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
              }
            )
          ),
        ],
      ),
    );
  }
}