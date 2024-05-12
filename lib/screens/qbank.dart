import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QBank extends StatefulWidget {
  const QBank({super.key});
  @override
  State<QBank> createState() => QBankState();
}

class QBankState extends State<QBank> {
  final Stream<QuerySnapshot> _questionStream = FirebaseFirestore.instance.collection('question-bank').orderBy("Module").snapshots();
  String? _selectedOption = 'DMS'; // Initial value
  final courses = {'DMS':'Discrete Mathematical Structures', 'DS':'Data Structures','COA':'Computer Organization and Architecture', 'DBMS':'DataBase Management Systems', 'OS':'Operating Systems', 'FLAT':'Formal Languages and Automata Theory'};
  final modules = ["1","2","3","4","5"];

  deleteUser(String docID) async {
    FirebaseFirestore.instance.collection('question-bank').doc(docID).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        centerTitle: true,
        backgroundColor: Colors.amber,
        //leading: IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back_sharp))
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/qform');
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          padding: const EdgeInsets.all(20),
          child: DropdownButtonFormField<String>(
            // hint: const Text("Select"),
            value: _selectedOption,
            items: courses.keys.map((String key) {
              return DropdownMenuItem <String>(
                value: key,
                child: Text(key)
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedOption = newValue;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Course',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(child: Container(
          padding: EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot>(
            stream: _questionStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child:SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
              }

              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  if((data["Question"] == null)||(data["Course"] == null)||(data["Option1"] == null)||(data["Option2"] == null)||(data["Option3"] == null)||(data["Option4"] == null)||(data["CorrectOption"] == null)||(data["Module"] == null)) {
                    print(document.id);
                  }
                  if((data["Question"] == null)||(data["Course"] == null)||(data["Option1"] == null)||(data["Option2"] == null)||(data["Option3"] == null)||(data["Option4"] == null)||(data["CorrectOption"] == null)||(data["Module"] == null)||(data["Course"] != courses[_selectedOption])) {
                    return SizedBox.shrink();
                  }
                  else {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${data['Question']} \n(Module ${data["Module"]})", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("1. ${data['Option1']}"),
                        Text("2. ${data['Option2']}"),
                        Text("3. ${data['Option3']}"),
                        Text("4. ${data['Option4']}"),
                        const SizedBox(height: 8),
                        Text("Correct Option: ${data['CorrectOption'].substring(6)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle edit test action
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white
                              ),
                              child: const Text('Edit'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Handle delete test action
                                setState(() {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Confirm delete'),
                                      content: Text('Are you sure you want to delete this question?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context, rootNavigator: true)
                                                .pop(false);
                                          },
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context, rootNavigator: true)
                                                .pop(true);
                                            deleteUser(document.id);
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                        const Divider(), // Add a divider
                      ],
                    ),
                  );
                  }
                }).toList(),
              );
            },
          ),
        )),
        ]
      )
    );
  }
}
