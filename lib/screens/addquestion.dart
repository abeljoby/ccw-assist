import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionForm extends StatefulWidget {
  const QuestionForm({super.key});
  @override
  QuestionFormState createState() => QuestionFormState();
}

class QuestionFormState extends State<QuestionForm> {
  String? Course;
  String? Option1;
  String? Option2;
  String? Option3;
  String? Option4;
  String? CorrectOption;
  String? Module;
  String? Question;

  final courses = {'DMS':'Discrete Mathematical Structures', 'DS':'Data Structures','COA':'Computer Organization and Architecture', 'DBMS':'DataBase Management Systems', 'OS':'Operating Systems', 'FLAT':'Formal Languages and Automata Theory'};
  final modules = {"1":1,"2":2,"3":3,"4":4,"5":5};

  final _formKey = GlobalKey<FormState>();

  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add question', style: TextStyle(color: Colors.yellow)),
        iconTheme: const IconThemeData(
          color: Colors.yellow, //change your color here
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: 
        Form(key: _formKey,
        child: SizedBox(height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Row(children: [Expanded(child:DropdownButtonFormField<String>(
          validator: (value) {
            if (value == null || value.isEmpty || value == 'Select') {
              return 'Please select a course';
            }
            return null;
          },
          hint: const Text("Select"),
          value: Course,
          items: courses.keys
            .map((e) => DropdownMenuItem(value: courses[e], child: Text(e)))
            .toList(),
          onChanged: (String? newValue) {
            setState(() {
              Course = newValue;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Course',
            border: OutlineInputBorder(),
          ),
        ),),
        const SizedBox(width:20),
        Expanded(child: DropdownButtonFormField<String>(
          validator: (value) {
            if (value == null || value.isEmpty || value == 'Select') {
              return 'Please select a module';
            }
            return null;
          },
          hint: const Text("Select"),
          value: Module,
          items: modules.keys
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
          onChanged: (String? newValue) {
            setState(() {
              Module = newValue;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Module',
            border: OutlineInputBorder(),
          ),
        ),),
        ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter question',
          ),
          maxLines: 5,
          onChanged: (String? newValue) {
            setState(() {
              Question = newValue;
            });
          },
        ),
        const SizedBox(height: 20),
        RadioListTile<String?>(
          title: SizedBox(width: 300, child: TextFormField(
            validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Option 1',
            ),
            onChanged: (String? newValue) {
              setState(() {
                Option1 = newValue;
              });
            },
          )),
          value: "Option1", groupValue: CorrectOption,
          onChanged: (String? value) {
            setState(() {
              CorrectOption = value;
            });
          },
        ),
        RadioListTile<String?>(
          title: SizedBox(width: 300, child: TextFormField(
            validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Option 2',
            ),
            onChanged: (String? newValue) {
              setState(() {
                Option2 = newValue;
              });
            },
          )),
          value: "Option2", groupValue: CorrectOption,
          onChanged: (String? value) {
            setState(() {
              CorrectOption = value;
            });
          }
        ),
        RadioListTile<String?>(
          title: SizedBox(width: 300, child: TextFormField(
            validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Option 3',
            ),
            onChanged: (String? newValue) {
              setState(() {
                Option3 = newValue;
              });
            },
          )),
          value: "Option3", groupValue: CorrectOption,
          onChanged: (String? value) {
            setState(() {
              CorrectOption = value;
            });
          }
        ),
        RadioListTile<String?>(
          title: SizedBox(width: 300, child: TextFormField(
            validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Option 4',
            ),
            onChanged: (String? newValue) {
              setState(() {
                Option4 = newValue;
              });
            },
          )),
          value: "Option4", groupValue: CorrectOption,
          onChanged: (String? value) {
            setState(() {
              CorrectOption = value;
            });
          }
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.yellow),
            fixedSize: MaterialStateProperty.all(const Size(200, 80))
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to question bank.')),
              );
              final question = <String, dynamic>{
                "Question": Question,
                "Course": Course,
                "Module": modules[Module],
                "CorrectOption": CorrectOption,
                "Option1": Option1,
                "Option2": Option2,
                "Option3": Option3,
                "Option4": Option4,
                "Difficulty": ""
              };
              db.collection("question-bank").add(question).then((DocumentReference doc) => print('DocumentSnapshot added with ID: ${doc.id}'));
            }
          },
          child: const Text('Submit'),
        ),
        ]
        ),
        ),
        ),
        ),
      )
    );
  }
}
