import 'package:ccwassist/screens/generatepaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTest extends StatefulWidget {
  const CreateTest({super.key});
  @override
  State<CreateTest> createState() => _CreateTestState();
}

class _CreateTestState extends State<CreateTest> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController timeInput = TextEditingController();
  final MultiSelectController _controller = MultiSelectController();
  final durations = ['15 min','30 min', '60 min'];
  final courses = {'DMS':'Discrete Mathematical Structures', 'DS':'Data Structures','COA':'Computer Organization and Architecture', 'DBMS':'Database Management Systems', 'OS':'Operating Systems', 'FLAT':'Formal Languages and Automata Theory'};
  String? selectedduration;
  String? selectedcourse;
  int? questions = 0;
  late List<String> selectedmodules;

  final _formKey = GlobalKey<FormState>();

  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Test', style: TextStyle(fontWeight: FontWeight.bold)),
        // centerTitle: true,
        backgroundColor: Colors.amber,
        // leading: IconButton(onPressed: (){}, icon: const Icon(Icons.menu)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                TextFormField(
                  controller: dateInput,
                  decoration: const InputDecoration(
                    // icon: Icon(Icons.calendar_today),
                    labelText: "Enter Date"
                  ),
                  readOnly: true,
                  //set it true, so that user will not able to edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2100)
                    );
                    if (pickedDate != null) {
                      // print(pickedDate);
                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      // print(formattedDate);
                      setState(() {
                        dateInput.text =
                            formattedDate; //set output date to TextField value.
                      });
                    } else {}
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value == 'Select') {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: timeInput,
                  decoration: const InputDecoration(
                    // icon: Icon(Icons.access_time),
                    labelText: "Enter Start Time"
                  ),
                  readOnly: true,
                  //set it true, so that user will not able to edit text
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 0, minute: 0)
                    );
                    if (pickedTime != null) {
                      setState(() {
                        timeInput.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}'; //set output date to TextField value.
                      });
                    } else {}
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value == 'Select') {
                      return 'Please select a time';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: "Duration",
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  items: durations
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    selectedduration = val;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value == 'Select') {
                      return 'Please select a duration';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: "Course",
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  items: courses.keys
                      .map((e) => DropdownMenuItem(value: courses[e], child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    selectedcourse = val;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value == 'Select') {
                      return 'Please select a course';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Modules',style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 79, 77, 77)),)
                ),
                MultiSelectDropDown(
                  controller: _controller,
                  options: const <ValueItem>[
                    ValueItem(label: 'Module 1', value: "1"),
                    ValueItem(label: 'Module 2', value: "2"),
                    ValueItem(label: 'Module 3', value: "3"),
                    ValueItem(label: 'Module 4', value: "4"),
                    ValueItem(label: 'Module 5', value: "5"),
                  ],
                  maxItems: 5,
                  // selectedOptions: const [ValueItem(label: 'Module 1', value: 1)],
                  selectionType: SelectionType.multi,
                  chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                  dropdownHeight: 250,
                  optionTextStyle: const TextStyle(fontSize: 16),
                  selectedOptionIcon: const Icon(Icons.check_circle),
                  inputDecoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color.fromARGB(255, 79, 77, 77)))),
                  padding: const EdgeInsets.all(0),
                  onOptionSelected:(options) {
                    selectedmodules = _controller.selectedOptions.map((item) => item.value as String).toList();
                  },
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of questions';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Number of Questions'),
                  onChanged: (val) {
                    questions = int.parse(val);
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 50,),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final test = <String, dynamic>{
                        "Questions": questions,
                        "Course": selectedcourse,
                        "Modules": selectedmodules,
                        "StartDate": dateInput.text,
                        "StartTime": timeInput.text,
                        "Duration": selectedduration,
                        "Batch": "2023-24"
                      };
                      Navigator.push(context,MaterialPageRoute(builder: ((context) => GenerateQuestionPaper(data: test))));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Generated question paper.')),
                      );
                      //db.collection("tests").add(test).then((DocumentReference doc) => print('DocumentSnapshot added with ID: ${doc.id}'));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300, 60), // Specify the width and height
                    backgroundColor: Colors.amber, // Background color
                    foregroundColor: Colors.black, // Text color
                  ),
                  child: const Text('Generate Question Paper',style: TextStyle(fontSize: 20),),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
