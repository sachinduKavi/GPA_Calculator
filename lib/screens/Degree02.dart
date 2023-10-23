import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpa_calculator/SQL_helper.dart';
import 'package:gpa_calculator/UploadData.dart';
import 'package:gpa_calculator/screens/Results.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Degree01 extends StatefulWidget {
  const Degree01({super.key});

  @override
  State<Degree01> createState() => _Degree01State();
}

class _Degree01State extends State<Degree01> {
  // Instance variables
  List dataValues = [];
  List<Widget> yearWidgetList = [];
  // double gpaCalculated = 0;
  Map<String, double> scaleMap = {};
  bool stateInit = false;
  double gpaCalculated = 0;
  List<List<List<double>>> gpaCreditValueList = [];

  // Year number
  int yearNo = 0;

  // Fetching all results from sqlLight
  Future<List> fetchAllResults() async {
    var result = await SQLHelper.getAllResults();
    stateInit = true;
    return result;
  }

  // Finding number of years
  void findMax() {
    for(final value in dataValues) {
      int baseNo = int.parse(value['year_sem'].toString().split('_')[0]);
      while(baseNo > yearNo) {
        addNewWidget(++yearNo);
      }
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    // Initiate all async functions ...
    asyncFunctions();
    super.initState();
  }

  void asyncFunctions() async {
    await getSharedPreferences();
    await fetchAllResults().then((result) {
      setState(() {
        dataValues = result;
      });
    }
    );


    await SQLHelper.getScale().then((List result) {
      for(final scale in result) {
        scaleMap[scale['grade']] = scale['scale'];
      }
    });
    gpaCalculate();
    findMax();
  }



  // Calculating total GPA ...
  double gpaCalculate() {
    double totalGpa = 0;
    double totalCredits = 0;

    if(stateInit) {
      for (final values in dataValues) {
        totalCredits += values['credits'];
        totalGpa += values['credits'] * scaleMap[values['grade']];
      }
    }
    setState(() {
      gpaCalculated = (totalCredits != 0) ? (totalGpa / totalCredits): 0.0;
    });
    return (totalCredits != 0) ? (totalGpa / totalCredits): 0.0;
  }

  Future<bool> calculateYearGpa(int year) async{
    var result = await SQLHelper.getResultYear(year);
    List<List<double>> tempList = [];
    for(int i = 1; i <= 2; i++) {
      double totalGpa = 0;
      double totalCredits = 0;
      for(final value in result) {
        if(value['year_sem'] == "${year}_$i") {
          totalGpa += value['credits'] * scaleMap['${value["grade"]}'];
          totalCredits += value['credits'];
        }
      }
      tempList.add([(totalGpa/totalCredits).isNaN ?0:(totalGpa/totalCredits) , totalCredits]);
    }
    gpaCreditValueList.add(tempList);
    return true;
  }

  // Adding widgets to widget List
  void addNewWidget(int year) async{
    bool state = await calculateYearGpa(year);
    setState(() {
      yearWidgetList.add(Container(
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
                    // color: const Color(0xFFD9D9D9),
                      border: Border.all(
                        color: Colors.activeColor,
                          width: 3,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(14))
                  ),
                  child: Text("Year: $year", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.activeColor),),
                ),

                // GPA and credit amount
                Text("GPA: ${((gpaCreditValueList [year-1][0][0]*gpaCreditValueList[year-1][0][1]+gpaCreditValueList[year-1][1][0]*gpaCreditValueList[year-1][1][1])/(gpaCreditValueList[year-1][0][1]+gpaCreditValueList[year-1][1][1])).toStringAsFixed(2)} "
                    "\nTotal Credits: ${(gpaCreditValueList[year-1][0][1]+gpaCreditValueList[year-1][1][1]).toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),

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
                      // semesterClick(yearNo, index+1);
                      // print("$year $index");
                      Navigator.of(context).push(MaterialPageRoute(builder: (_){
                        return Results(year, index+1, degreeName);
                      }));
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
                          Text("GPA: ${gpaCreditValueList[year-1][index][0].toStringAsFixed(2)}", style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),),
                          Text(gpaCreditValueList[year-1][index][1].toStringAsFixed(0), style: const TextStyle(
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
  }
  String degreeName = "Unknown";
  Future<void> getSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      try{
        degreeName = preferences.getString("degree_name")!;
      }catch(e){
        print('$e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    late String classType;
    if(gpaCalculated >= 3.7) {
      classType = "1st Class";
    } else if (gpaCalculated >= 3.3){
      classType = "2nd Upper";
    } else if(gpaCalculated >= 3) {
      classType = "2nd Lower";
    }else {
      classType = "Ordinary";
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(degreeName),
        // leading: const Icon(Icons.menu, weight: 10,),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.activeColor,
                    width: 4,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(25))
                ),
                child: Center(
                  // Main Score display ...
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(classType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF9F9F9F))),

                      Text(gpaCalculated.toStringAsFixed(2), style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),),

                      const Text("Total GPA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF9F9F9F))),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      children: yearWidgetList,
                    )
                  ],
                ),
              )
            ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            addNewWidget(++yearNo);
          },
        backgroundColor: Colors.activeColor,
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        elevation: 200,
        backgroundColor: const Color(0xFF3C4B55),
        child:Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3)
            ),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.white,),
              title: const Text("My Profile", style: TextStyle(fontSize: 20, color: Colors.white),),
              onTap: () {
                Navigator.of(context).pushNamed("user_profile");
              },
            ),
          ),

          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3)
            ),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.white,),
              title: const Text("GPA Scale", style: TextStyle(fontSize: 20, color: Colors.white),),
              onTap: () {
                Navigator.of(context).pushNamed('scale');
              },
            ),
          ),

          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3)
            ),
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.white,),
              title: const Text("About", style: TextStyle(fontSize: 20, color: Colors.white),),
              onTap: () {
                print("Some click");
                Navigator.of(context).pushNamed("about");
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3)
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_sharp, color: Colors.white,),
              title: const Text("Logout", style: TextStyle(fontSize: 20, color: Colors.white),),
              onTap: () {
                systemLogout();
                print("System Logout");
              },
            ),
          ),


      ],
    ),
    )
    );
  }

  Future<void> systemLogout() async {
    // Deleting all shared preferences
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();

    // Deleting local sqflite database
    await SQLHelper.deleteDatabase();
    Navigator.of(context).pushNamed("loginPage");
  }

}
