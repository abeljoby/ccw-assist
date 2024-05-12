import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.amber,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text('Submit your feedback',style: TextStyle(fontSize: 20),),
              TextFormField(
                decoration: const InputDecoration(labelText: '\tEnter the subject'),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border:Border.all()
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '\t\tEnter your feedback here'
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              ElevatedButton(onPressed: (){}, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  fixedSize: const Size(200, 50),
                ),
                child: const Text('Submit',style: TextStyle(fontSize:20 ),))
              ],
            ),
        ),
      ),
    );
  }
}