import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ccwassist/screens/questionpaper.dart';

class ResultPage extends StatefulWidget {
  final Map<String,dynamic> data;
  final String id;
  final String email;
  final List<String> ans;
  const ResultPage({super.key,required this.id,required this.data,required this.ans,required this.email});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late int correct = 0;
  late int answered = 0;
  late int unanswered = 0;
  late int unvisited = 0;
  late int reviewed = 0;

  late Map<String,dynamic> testData = {};
  late String testID = '';
  late List<String> answers = [];
  late String emailID = '';

  @override
  void initState() {
    testID = widget.id;
    testData = widget.data;
    answers = widget.ans;
    emailID = widget.email;
    super.initState();
  }

  Future<List<Map<String,dynamic>>> getQuestionPaper(testID) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = 
    await FirebaseFirestore.instance.collection("tests")
    .doc(testID)
    .collection("question-paper")
    .orderBy("qno")
    .get();
    List<Map<String,dynamic>> _questions = snapshot.docs.map((q) => q.data()).toList();
    return _questions;
  }

  checkAnswers (List<Map<String,dynamic>> questionpaper,List<String> ans) {
    int correct = 0;
    int answered = 0;
    int unanswered = 0;
    int unvisited = 0;
    int reviewed = 0;
    for (var ques in questionpaper) {
      if(ques['CorrectOption'] == ans[ques['qno']-1]) {
        correct++;
        answered++;
      }
      else if (ans[ques['qno']-1] == '') {
        unanswered++;
      }
      else if (ans[ques['qno']-1] == 'R') {
        reviewed++;
      }
      else if (ans[ques['qno']-1] == 'NV') {
        unvisited++;
      }
      else {
        answered++;
      }
    }
    return [correct,answered,unanswered,unvisited,reviewed];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder(
        future: getQuestionPaper(testID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: Text('CCW Test 1')),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(title: Text('CCW Test 1')),
              body: Center(child: Text("Error fetching the data")),
            );
          } else if (snapshot.hasData){
            var questionPaper = snapshot.data as List<Map<String,dynamic>>;
            var result = checkAnswers(questionPaper,answers);
            correct = result[0];
            answered = result[1];
            unanswered = result[2];
            unvisited = result[3];
            reviewed = result[4];
            var noOfQuestions = questionPaper.length;
            return Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ColoredBox(
                      color: Colors.indigo,
                      child: Center(
                        child: Text(
                          testData['Course'],
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: 100,
                    width: double.infinity,
                    color: Colors.white,
                    child: Text(
                      '${testData['StartTime']}\n${testData['StartDate']}\nCourse: ${testData['Course']}\nModules ${testData['Modules'].toString().substring(1, testData['Modules'].toString().length - 1)}',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: double.infinity,
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        'Marks : $correct/$noOfQuestions',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  const ListTile(
                    title: Text(
                      'No of Questions',
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text('$answered')),
                    title: const Text('Answered'),
                    dense: true, // Set dense to true for compact spacing
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Text('$unanswered')),
                    title: const Text('Not Answered'),
                    dense: true, // Set dense to true for compact spacing
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Text('$unvisited')),
                    title: const Text('Not Visited'),
                    dense: true, // Set dense to true for compact spacing
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.purpleAccent,
                        child: Text('$reviewed')),
                    title: const Text('Marked for review'),
                    dense: true, // Set dense to true for compact spacing
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                        color: Colors.amber,
                        shadowColor: Colors.black,
                        elevation: 7,
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Solutions'),
                              subtitle:
                                  const Text('Question Paper Analysis and Solutions'),
                              onTap: () {
                                Navigator.push(context,MaterialPageRoute(builder: ((context) => QuestionPaper(data: testData,id: testID))));
                              },
                            )
                          ],
                        )),
                  ),
                ],
              ),
            );
          }
          else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20.0),
                  Text(
                    'Please Wait while Questions are loading..',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.none,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      )
    );
  }
}
