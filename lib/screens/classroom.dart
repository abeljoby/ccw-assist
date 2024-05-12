import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Classroom extends StatefulWidget {
  const Classroom({super.key});
  @override
  State<Classroom> createState() => ClassroomState();
}

class ClassroomState extends State<Classroom> {
  final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance.collection('users').where('userType',isEqualTo: "Student").snapshots();
  String? _selectedOption = '2023-24'; // Initial value
  final years = ['2023-24', '2024-25', '2025-26', '2026-27', '2027-28'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom'),
        centerTitle: true,
        backgroundColor: Colors.amber,
        //leading: IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back_sharp))
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/qform');
      //   },
      //   child: const Icon(Icons.add),
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          padding: const EdgeInsets.all(20),
          child: DropdownButtonFormField<String>(
            // hint: const Text("Select"),
            value: _selectedOption,
            items: years.map((String year) {
              return DropdownMenuItem <String>(
                value: year,
                child: Text(year)
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedOption = newValue;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Batch',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(child: Container(
          padding: EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot>(
            stream: _userStream,
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
                  // if((data["Question"] == ))
                    // print(document.id);
                  return (data["batch"] != _selectedOption)?SizedBox.shrink():
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${data['name']} (${data['ktuID']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Divider(), // Add a divider
                      ],
                    ),
                  );
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
