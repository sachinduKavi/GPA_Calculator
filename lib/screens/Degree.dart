import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gpa_calculator/SQL_helper.dart';
import 'package:gpa_calculator/screens/Results.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Degree extends StatefulWidget {
  const Degree({super.key});

  @override
  State<Degree> createState() => _DegreeState();
}

class _DegreeState extends State<Degree> {
  List<Widget> yearList = [];

  void semesterClick(int year, int semester) {
    print("$year $semester");
    Navigator.of(context).push(MaterialPageRoute(builder: (_){
      return Results(year, semester, "computer Science");
    }));
  }

  int count = 0;

  @override
  void initState() {
    super.initState();
    initYears();
    getResults(1);
  }

  Future<void> updateNumberOfYears() async {
    print('Counter Updated $count');
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt("no_of_years", count);
  }



  Future<void>  initYears() async {
    print('Initialization year');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // preferences.clear();
    int? counter = await preferences.getInt("no_of_years");
    print("Counter: $counter");
    for (int i = 0; i < counter!; i++) {
      createNewYear(i+1);
    }
  }

  Future<List> getResults(int year) async{
    var result = await SQLHelper.getResultYear(year);
    print('Result: $result');
    return result;
  }

  void createNewYear(int yearNo) {
    setState(() {
      yearList.add(Container(
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF6F61C0),
              width: 5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Year number
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 2,
                          color: const Color(0xFF707070)
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(18))
                  ),
                  child: Text("Year: ${++count}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.activeColor),),
                ),

                // GPA and credit amount
                Text("Total GPA: GG | Total Credits: CC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),

                // Close cross button
                const Icon(Icons.close, color: Colors.red,)
              ],
            ),

            // Divider
            const Padding(
              padding: EdgeInsets.all(3),
              child: Divider(
                thickness: 3,
              ),
            ),

            // Semesters generate here
            ListView.builder(
              physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: 2,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      semesterClick(yearNo, index+1);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: const Color(0xFF707070)
                          ),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.mainColor
                      ),

                      // color: Colors.mainColor,
                      // width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceAround,
                        children: [
                          Text("Semester ${index + 1}", style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),),
                          Text("GPA NO", style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),),
                          Text("CC", style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),)
                        ],
                      ),
                    ),
                  );
                })
          ],
        ),

      ));
    });
    updateNumberOfYears();
  }


Future<void> fetchAllResults() async {
    var result = await SQLHelper.getAllResults();
    print('Results everything: $result');
  }

  // main entry of this screen ... ***
  @override
  Widget build(BuildContext context) {
    print('hello');
    fetchAllResults();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Computer Science and Technology Degree", style: TextStyle(fontSize: 24), overflow: TextOverflow.ellipsis,),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFE9004),
                      width: 5,
                    ),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Class Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9F9F9F)),),
                      Text("GPA Value", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),),
                      Text("GPA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9F9F9F)),)
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              thickness: 4,
              color: Color(0xFF707070),
              height: 10,
            ),

            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Column(
                    children: yearList,
                  )
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          print('Button pressed');
            // Dialog box with textField
          _createNewYearDialog(context);
        },
        backgroundColor: const Color(0xFFFE9004),
        child: const Icon(Icons.add),
      )
    );
  }


  void _createNewYearDialog(BuildContext context) {
    showDialog(context: context,
        builder: (BuildContext context) {
        bool errorState = false;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)
            ),
            title: Center(child: Text("Create year ${count + 1}", style: const TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold), )),
            content: SizedBox(
              height: 80,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(onPressed: () {
                          // OK button commands

                          createNewYear(count+1);
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                        ),
                        child: const Text("Yes"),
                        ),
                        ElevatedButton(onPressed: () {
                          Navigator.of(context).pop();
                        },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),

                          ),
                          child: const Text("No"),
                        )
                      ],
                    ),
                  )
                ],
              )
            )
          );
        });
  }


}
