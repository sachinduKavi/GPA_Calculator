import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  List<Widget> dynamicWidget = [];
  List<Widget> semesterList = [];



  void addDynamicSemester() {
    setState(() {
      semesterList.add(const Text("Sachindu"));
    });
  }

  void addDynamicYear() {


    setState(() {
      dynamicWidget.add(
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            color: Color(0xFFCCCCCC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [


                Padding(padding:const EdgeInsets.all(10), child: Text("Year ${dynamicWidget.length + 1}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),


                ListView(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget> [
                    Column(
                      // Dynamic semester
                      children: semesterList,
                    )
                  ]
                ),


                ElevatedButton(
                    onPressed: () {
                      print('Semester Press');
                      addDynamicSemester();
                    },
                    child: const Text("Add Semester")
                ),


              ],
            ),
          ),
        )
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
      ),
      body: ListView(
        children: [
          // Dynamic widget appear here
          Column(
            children: dynamicWidget,
          ),

          ElevatedButton(
              onPressed: () {
                addDynamicYear();
              },
              child: Text("Add Year"))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addDynamicYear();
          print('Button Pressed');
        },
        child: const Icon(Icons.add,
        ),
      ),
    );
  }
}
