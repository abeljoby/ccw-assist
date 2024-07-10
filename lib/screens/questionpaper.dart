import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:ccwassist/screens/scheduledtests.dart';

class QuestionPaper extends StatefulWidget {
  final Map<String,dynamic> data;
  final String id;
  const QuestionPaper({super.key, required this.data, required this.id});

  @override
  State<QuestionPaper> createState() => _QuestionPaperState();
}

class _QuestionPaperState extends State<QuestionPaper> {
  late Map<String,dynamic> dataCopy = {};
  late String testID = "";

  Future<List<QueryDocumentSnapshot<Map<String,dynamic>>>> getQuestionPaper(testID) async {
    var snapshot = await FirebaseFirestore.instance.collection('tests').doc(testID).collection('question-paper').orderBy("qno").get();
    List<QueryDocumentSnapshot<Map<String,dynamic>>> questions = snapshot.docs;
    return questions;
  }

  @override
  void initState() {
    super.initState();
    dataCopy = widget.data;
    testID = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Paper', style: TextStyle(color: Colors.yellow)),
        // centerTitle: true,
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
                Text('Date: ${dataCopy["StartDate"]}\nTime: ${dataCopy["StartTime"]}\nDuration: ${dataCopy["Duration"]}\nCourse: ${dataCopy["Course"]}\nModules: ${dataCopy["Modules"].toString().substring(1, dataCopy['Modules'].toString().length - 1)}',textAlign:TextAlign.center,style: TextStyle(color: Colors.black,)),                // Add more details as needed
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getQuestionPaper(testID),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<Map<String,dynamic>> questionPaper = snapshot.data!.map((q) => q.data()).toList();
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