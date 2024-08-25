import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:ccwassist/screens/scheduledtests.dart';

class GenerateQuestionPaper extends StatefulWidget {
  final Map<String, dynamic> data;
  const GenerateQuestionPaper({super.key, required this.data});

  @override
  State<GenerateQuestionPaper> createState() => _GeneratePaperState();
}

class _GeneratePaperState extends State<GenerateQuestionPaper> {
  late Map<String,dynamic> dataCopy;
  List<Map<String,dynamic>> questionPaper = [];

  Future<List<Map<String,dynamic>>> generateQuestionPaper(Map<String,dynamic> dataCopy) async {
    late List<String> requiredModules = dataCopy["Modules"];
    final QuerySnapshot<Map<String, dynamic>> snapshot = 
    await FirebaseFirestore.instance.collection("question-bank")
    .where("Course",isEqualTo: dataCopy["Course"])
    .where("Module",whereIn: requiredModules)
    .get();
    List<Map<String,dynamic>> courseQuestions = snapshot.docs.map((q) => parseQuestion(q)).toList();
    int totalQuestions = dataCopy['Questions'];

    // Calculate number of questions per module
    int questionsPerModule = totalQuestions ~/ requiredModules.length;
    // Calculate number of extra questions
    int extraQuestions = totalQuestions % requiredModules.length;
    // Shuffle the questions
    courseQuestions.shuffle();
    List<Map<String,dynamic>> selectedQuestions = [];

    // Select random questions from each required module
    requiredModules.forEach((module) {
      List<Map<String,dynamic>> moduleQuestions = courseQuestions.where((q) => q["Module"] == module).toList();
      int questionsToAdd = questionsPerModule;
      if (extraQuestions > 0) {
        questionsToAdd++;
        extraQuestions--;
      }
      questionsToAdd = min(questionsToAdd,moduleQuestions.length);
      if(questionsToAdd < questionsPerModule) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient number of question in module $module')),
        );
      }
      selectedQuestions.addAll(moduleQuestions.sublist(0, questionsToAdd));
    });
    return selectedQuestions;
  }

  Map<String,dynamic> parseQuestion(QueryDocumentSnapshot<Map<String, dynamic>> q) {
    Map<String,dynamic> qdoc = q.data();
    qdoc["reference"] = q.reference.id;
    return qdoc;
  }

  @override
  void initState() {
    super.initState();
    dataCopy = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Paper', style: TextStyle(color: Colors.yellow)),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.yellow, //change your color here
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Container for additional details (date, time, etc.)
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
          // Scrollable list of questions
          Expanded(
            child: FutureBuilder(
              future: generateQuestionPaper(dataCopy),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  questionPaper = snapshot.data as List<Map<String,dynamic>>;
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
          Container(
            color: Colors.amber,
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generated question paper.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    fixedSize: const Size(150, 50)
                  ),
                  child: const Text('Regenerate',style: TextStyle(fontSize: 18),),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DocumentReference<Map<String,dynamic>> testref = await FirebaseFirestore.instance.collection("tests").add(dataCopy);
                    String testid = testref.id;
                    // List<String> selectedreferences = [];
                    // selectedreferences.addAll(questionPaper.map((q) => q["reference"]));
                    // final qp = <String, dynamic>{
                    //   "Question":selectedreferences
                    // };
                    // FirebaseFirestore.instance.collection("tests").doc(testid).collection("question-paper").doc("Questions").set(qp).then((value) => null);
                    for (int index = 1; index <= questionPaper.length; index++) {
                      questionPaper.elementAt(index-1)["qno"] = index;
                      FirebaseFirestore.instance.collection("tests").doc(testid).collection("question-paper").doc("$index").set(questionPaper.elementAt(index-1)).then((value) => null);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added test to schedule.'))
                    );
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: ((context) => const ScheduledTests())),ModalRoute.withName('/'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    fixedSize: const Size(150, 50)
                  ),
                  child: const Text('Create',style: TextStyle(fontSize: 18),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}