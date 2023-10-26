  import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpa_calculator/SQL_helper.dart';
import 'package:gpa_calculator/UploadData.dart';

class Results extends StatefulWidget {

  int year, semester;
  String degreeName;
  bool uploadState = true;
  Results(this.year, this.semester, this.degreeName, {super.key}){
    if(degreeName == "Unknown") {
      uploadState = false;
    }
  }


  @override
  State<Results> createState() => _ResultsState(year, semester, uploadState);
}



class _ResultsState extends State<Results> {
  int year, semester;
  bool uploadState;
  double finalGpa = 0;
  List<Widget> moduleList = [];
  List resultData = [];
  Map<String, double> scaleMap = {};
  List<String> gradeList = ["A+", "A", "A-", "B+", "B", "B-", "C+", "C", "C-", "D+", "D", "E"];
  String selectedValue = "A+";
  TextEditingController moduleNameController = TextEditingController();
  TextEditingController creditController = TextEditingController();
  int changeCount = 0;
  _ResultsState(this.year, this.semester, this.uploadState);


  Future<void> _addResultSql(String moduleName, int credits, String grade) async {
    await SQLHelper.createResult(moduleName, credits, grade, semester, year);
    callAsyncFunctions();
  }

  Future<void> _getResults() async {
    final data = await SQLHelper.getResults(year, semester);
    print("Data: $data");
    resultData = data;
    moduleList.clear();

    for(int i = 0; i < data.length; i++) {
      addModule(data[i]['course_id'], data[i]['module_name'], data[i]['credits'], data[i]['grade']);
    }
    updateGPA();
  }

  Future<void> deleteResultsRe(int courseID) async{
    await SQLHelper.deleteResult(courseID);
    callAsyncFunctions();
  }

  void updateGPA() {
    print('Update  GPA');
    finalGpa = 0;
    double totalGpa = 0;
    double totalCredits = 0;
    print("Result data: $resultData");
    for(final val in resultData) {
      totalGpa += val['credits'] * scaleMap[val['grade']];
      totalCredits += val['credits'];
    }
    print('totalGpa $totalGpa $totalCredits');
    setState(() {
      finalGpa = (totalCredits != 0) ? (totalGpa / totalCredits): 0.0;
    });
  }

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    callAsyncFunctions();
    getScaleValues();
  }

  void callAsyncFunctions() async {
    await _getResults();
  }

  Future<void> getScaleValues() async{
    List scaleData = await SQLHelper.getScale();
    print(scaleData);
    for(int i = 0; i < scaleData.length; i++) {
      scaleMap[scaleData[i]['grade']] = scaleData[i]['scale'];
    }
    updateGPA();
  }


  void addModule(int courseId, String moduleName, int credits, String grade) {
    setState(() {
      moduleList.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFE8E3FF),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  width: 3,
                  color: Colors.mainColor,
                )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Module name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFFBCBCBA)),),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(moduleName, style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold), softWrap: true,)),
                    InkWell(
                      onTap: () {
                        changeCount++;
                        deleteResultsRe(courseId);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(50))
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 15,),
                      ),
                    ),
                  ],

                ),
                Text("Credits: $credits  |  Grade: $grade")
              ],
            ),
          )
      );
    });

  }

  Future<void> syncAndGo() async {
    await UploadData.uploadAllResults(context).then((status) {
      print('Upload data completed ...');
      if(status) {
        changeCount = 0;
      }
    });
  }

  // Screen entry ...
  @override
  Widget build(BuildContext context) {
    late String classType;
    finalGpa = double.parse(finalGpa.toStringAsFixed(2));
    if(finalGpa >= 3.7) {
      classType = "1st Class";
    } else if (finalGpa >= 3.3){
      classType = "2nd Upper";
    } else if(finalGpa >= 3) {
      classType = "2nd Lower";
    }else {
      classType = "Ordinary";
    }
    print('Calculated GPA : $finalGpa   $classType');
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading:  InkWell(child: const Icon(Icons.arrow_back), onTap: () {
            // Prompt open if count > 0
            print('Change Count: $changeCount');
              if(changeCount > 0 && uploadState) {
              showDialog(context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context){
                return AlertDialog(
                  title: const Text("Data is not synchronized with the cloud"),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: () {
                        Navigator.of(context).pop();
                        syncAndGo();
                      },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.blueAccent)),
                          child: const Text("Sync",style: TextStyle(fontSize: 17),)),

                      ElevatedButton(onPressed: () {
                        Navigator.of(context).pushNamed("degree");
                      },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.red)),
                          child: const Text("Skip Now",style: TextStyle(fontSize: 17),))
                    ],
                  ),
                );
              });
            }else {
                Navigator.of(context).pushNamed("degree");
              }

            // Navigator.of(context).pushNamed('degree');
          },),
          title: Text("Year: $year | Semester: $semester", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: IconButton(icon: const Icon(Icons.cloud_done), onPressed: uploadState? () {
                UploadData.uploadAllResults(context).then((status) {
                print('Upload data completed ...');
                  if(status) {
                    changeCount = 0;
                  }
                });
              }:null,),
            )

          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.activeColor,
                    width: 5
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(classType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9F9F9F)),),
                    Text(finalGpa.toStringAsFixed(2), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),),
                    const Text("semester GPA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9F9F9F)),)
                  ],
                ),
              ),


              //Single child View
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView(
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          Column(
                              children: moduleList
                          )
                        ],
                      ),

                      // Add new module Form field
                      SizedBox(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                  width: 3,
                                  color: const Color(0xFFE9E9E8)
                              )
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Add New Module", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFBCBCBA)),),
                              Container(
                                margin: const EdgeInsets.all(10),
                                child: TextField(
                                  textCapitalization: TextCapitalization.words,
                                  controller: moduleNameController,
                                    decoration: const InputDecoration(
                                        hintText: "Module Name",
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(width: 3, color: Color(0xFFE9E9E8))
                                        )
                                    )
                                ),
                              ),

                              Row(
                                children: [

                                  Container(
                                    margin: const EdgeInsets.all(10),
                                    width: 100,
                                    child: TextField(
                                      controller: creditController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            hintText: "Credits",
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(width: 3, color: Color(0xFFE9E9E8))
                                            )
                                        )
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.only(left: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        border: Border.all(
                                          width: 1,
                                        )
                                    ),
                                    margin: const EdgeInsets.all(10),
                                    width: 80,
                                    child: DropdownButton<String>(
                                        value: selectedValue,
                                        icon: const Icon(Icons.keyboard_arrow_down),
                                        elevation: 16,
                                        style: const TextStyle(color: Colors.deepPurple),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (String? value) {
                                          // This is called when the user selects an item.
                                          setState(() {
                                            selectedValue = value!;
                                          });
                                        },
                                        items: gradeList.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList()
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: ElevatedButton(
                                    onPressed: (){
                                      changeCount++;
                                      print('${moduleNameController.text} ${creditController.text} $selectedValue working');
                                      // addModule(moduleNameController.text, int.parse(creditController.text), selectedValue);
                                      _addResultSql(moduleNameController.text.trim(), int.parse(creditController.text), selectedValue);
                                      print('Record Added');
                                      setState(() {
                                        moduleNameController.text = "";
                                        creditController.text = "";
                                      });
                                    },
                                    child: const Text("Add New")
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )



            ],
          ),
        ),

      ),
    );
  }
}
