
import 'dart:async';
// import 'package:ccwassist/screens/quiz_result.dart';
import 'package:ccwassist/screens/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// create the TestScreen widget
// I'm taking the Stateful widget because it's going to be our parent widget and all the functions and variables will be in this widget so we will need to change state of our widget.
class TestScreen extends StatefulWidget {
  final Map<String,dynamic> data;
  final String id;
  final String email;
  const TestScreen({super.key, required this.id, required this.data, required this.email});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin {
  late Map<String,dynamic> testData = {};
  late List<String> answers = [];
  late String testID = "";
  late String emailID = "";
  late AnimationController _controller;
  late int noOfQuestions = 0;
  // Timer? timer;
  // int seconds = 60;
  int levelClock = 180;
  // create an index to loop through _questions
  int index = 0;
  // create a score variable
  int score = 0;
  // create a boolean value to check if the user has clicked
  bool isPressed = false;
  //answers option
  // create a function to display the next question
  bool isAlreadyanswers = false;
  List<String> optionList = ['Option1','Option2','Option3','Option4'];

  // final List<Question> _questions = [
  //   Question(
  //     id: '10',
  //     title: 'What is 2 + 2 ?',
  //     options: {'5': false, '30': false, '4': true, '10': false},
  //   ),
  //   Question(
  //     id: '11',
  //     title: 'What is 10 + 20 ?',
  //     options: {'50': false, '30': true, '40': false, '10': false},
  //   )
  // ];

  // startTimer() {
  //   Timer.periodic(const Duration(seconds: 1), (timer) {
  //     setState(() {
  //       seconds--;
  //     });
  //   });
  // }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    testData = widget.data;
    testID = widget.id;
    emailID = widget.email;
    answers = List.generate(testData['Questions'], (index) => 'NV');
    // startTimer();
    switch (testData["Duration"]) {
      case "15 min":
        levelClock = 900;
        break;
      case "30 min": 
        levelClock = 1800;
        break;
      case "60 min":
        levelClock = 3600;
        break;
    }
    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
                levelClock) // gameData.levelClock is a user entered number elsewhere in the applciation
        );
    _controller.forward();
  }

  void nextQuestion(int questionLength) {
    if (index == questionLength - 1) {
    } else {
      setState(() {
        index++;
        isPressed = false;
        isAlreadyanswers = false;
        answers[index] = answers[index]=='R'?'R':'';
      }); 
    }
  }

  void previousQuestion(int questionLength) {
    if (index == 0) {
    } else {
      setState(() {
        index--;
        isPressed = false;
        isAlreadyanswers = false;
        // answers = "";
      });
    }
  }

  // create a function for changing color
  void checkAnswerAndUpdate(bool value) {
    if (isAlreadyanswers) {
      return;
    } else {
      if (value == true) {
        score++;
      }
      setState(() {
        isPressed = true;
        isAlreadyanswers = true;
      });
    }
  }

  // create a function to start over
  void startOver() {
    setState(() {
      index = 0;
      score = 0;
      isPressed = false;
      isAlreadyanswers = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${testData['Course']}',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.amber,
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Submission"),
                    content: const Text("Are you sure you want to submit?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ResultPage(id: testID,data: testData,ans: answers,email: emailID)),ModalRoute.withName('/')),
                        child: const Text('SUBMIT'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(90, 20),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "SUBMIT",
                style: TextStyle(fontSize: 11),
              ),
            ),
          )
        ],
      ),
      body: Center(
          child: Column(
            children: [
              Container(
                height: 80,
                width: double.infinity,
                color: Colors.indigo[800],
                child: Center(
                  child: Countdown(
                    animation: StepTween(
                      begin: levelClock, // THIS IS A USER ENTERED NUMBER
                      end: 0,
                    ).animate(_controller),
                  ),
                ),
              ),
              FutureBuilder(
                future: getQuestionPaper(testID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Scaffold(
                      appBar: AppBar(title: Text('CCW Test 1')),
                      body: Expanded(child: Center(child: CircularProgressIndicator())),
                    );
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return Scaffold(
                      appBar: AppBar(title: Text('CCW Test 1')),
                      body: Expanded(child: Center(child: Text("Error fetching the data"))),
                    );
                  } else if (snapshot.hasData){
                    var questionPaper = snapshot.data as List<Map<String,dynamic>>;
                    noOfQuestions = questionPaper.length;
                    return Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Question ${index + 1}/${noOfQuestions}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(questionPaper[index]["Question"]),
                              const SizedBox(height: 20),
                              Column(
                                children: [
                                  RadioListTile(
                                    title: Text(questionPaper[index]['Option1']),
                                    value: 'Option1',
                                    groupValue: answers[index],
                                    onChanged: (val) {
                                      setState(() {
                                        answers[index] = val!;                                    
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: Text(questionPaper[index]['Option2']),
                                    value: 'Option2',
                                    groupValue: answers[index],
                                    onChanged: (val) {
                                      setState(() {
                                        answers[index] = val!;                                    
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: Text(questionPaper[index]['Option3']),
                                    value: 'Option3',
                                    groupValue: answers[index],
                                    onChanged: (val) {
                                      setState(() {
                                        answers[index] = val!;                                    
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: Text(questionPaper[index]['Option4']),
                                    value: 'Option4',
                                    groupValue: answers[index],
                                    onChanged: (val) {
                                      setState(() {
                                        answers[index] = val!;                                    
                                      });
                                    },
                                  ),
                                ]
                              ),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     nextQuestion(noOfQuestions);
                              //   },
                              //   child: const Text('Next Question'),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: Center(
                        child: SingleChildScrollView(
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
                        ),
                      ),
                    );
                  }
                }
              )
            ],
          ),
        ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                color: Colors.grey,
              ),
              Container(
                height: 120,
                width: double.infinity,
                color: Colors.amber,
                child: Center(
                  child: Text(
                    testData['Course'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Container(
                height: 80, // Adjust the height as needed
                color:
                    Colors.indigo.shade700, // Background color for the header
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle "Question Paper" button press
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(150, 50)),
                            child: const Text('Question Paper'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Handle "Instructions" button press
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(150, 50)),
                            child: const Text('Instructions'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const ListTile(
                title: Text(
                  'Questions',
                ),
                //    subtitle: Text('Legend:'),
              ),
              const ListTile(
                leading: CircleAvatar(backgroundColor: Colors.green),
                title: Text('Answered'),
                dense: true, // Set dense to true for compact spacing
                visualDensity: VisualDensity(
                    vertical: -4), // Adjust the vertical density
              ),
              const ListTile(
                leading: CircleAvatar(backgroundColor: Colors.red),
                title: Text('Not Answered'),
                dense: true, // Set dense to true for compact spacing
                visualDensity: VisualDensity(
                    vertical: -4), // Adjust the vertical density
              ),
              const ListTile(
                leading: CircleAvatar(backgroundColor: Colors.grey),
                title: Text('Not Visited'),
                dense: true, // Set dense to true for compact spacing
                visualDensity: VisualDensity(
                    vertical: -4), // Adjust the vertical density
              ),
              const ListTile(
                leading: CircleAvatar(backgroundColor: Colors.purpleAccent),
                title: Text('Marked for review'),
                dense: true, // Set dense to true for compact spacing
                visualDensity: VisualDensity(
                    vertical: -4), // Adjust the vertical density
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 5,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                    noOfQuestions,
                    (index) => questionBox(
                        index + 1)), // Disable GridView's scrolling
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.indigo.shade800,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (index > 0) {
                  previousQuestion(noOfQuestions);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('This is the first question.')),
                  );
                }
              },
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  answers[index] = 'R';
                  nextQuestion(noOfQuestions);
                });
              },
              child: Text('Review'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  nextQuestion(noOfQuestions);
                });
              },
              child: Text('Save'),
            ),
            IconButton(
              onPressed: () {
                if (index < noOfQuestions - 1) {
                  nextQuestion(noOfQuestions);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('This is the last question.')),
                  );
                }
              },
              icon: Icon(Icons.arrow_forward),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );        
  }

  Widget questionBox(int number) {
    Color color = Colors.grey;
    if (answers[number-1] == '') {
      color = Colors.red; // Not Answered
    } else if (answers[number-1] == 'R') {
      color = Colors.purpleAccent; // Marked for Review
    } else if (answers[number-1] == 'NV'){
      color = Colors.grey; // Not Visited
    } else /* if ((answers[number-1] != '')&&(answers[number-1] != 'NV')&&(answers[number-1] != 'R')) */{
      color = Colors.green; // Answered
    }
    return InkWell(
      onTap: () {
        // Handle circle click
        //   print('Clicked on question $number');
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(number.toString())),
      ),
    );
  }
}

class Countdown extends AnimatedWidget {
  Countdown({final Key key = const Key(""), required this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Text(
      "$timerText",
      style: const TextStyle(
        fontSize: 30,
        color: Colors.white,
      ),
    );
  }
}
