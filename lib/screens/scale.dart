import 'package:flutter/material.dart';
import 'package:gpa_calculator/SQL_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Scale extends StatefulWidget {
  const Scale({super.key});

  @override
  State<Scale> createState() => _ScaleState();
}



class _ScaleState extends State<Scale> {
  // instance variables
  List<Widget> scaleWidgets = [];
  Map<String, double> scaleMap = {};
  bool userAccount = true;

  @override
  void initState() {
    // TODO: implement initState
    // addScaleWidget();
    fetchScale();
    super.initState();
  }

  Future<void> fetchScale() async {
    var scaleList = await SQLHelper.getScale();
    for(Map value in scaleList) {
      addScaleWidget(value['grade'], value['scale']);
    }
    setState(() {
      // print('Scale Widget $scaleWidgets');
    });
  }

  Future<void> updateScale(String grade) async{
    showDialog(context: context, builder: (BuildContext context) {
      return const AlertDialog(
        icon: Icon(Icons.error_outline, size: 50, color: Colors.red,),
        title: Text("Sorry scale editing is not allowed!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
      );
    });
  }

  // Adding widgets to the list
  void addScaleWidget(String grade, double scale) {
      scaleWidgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black38, width: 2)
          ),
          margin: const EdgeInsets.only(top: 10),
          child: Row(
            children: [

              Expanded(
                child: Text(grade, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              ),

              const VerticalDivider(),

              Expanded(
                child: Text("$scale", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),

              Expanded(
                child: IconButton(icon: const Icon(Icons.edit), color: Colors.activeColor,
                onPressed: () {
                  _bottomSheet(grade, scale);
                  print('Grade : $grade');

                },)
              ),
            ],
          ),
        )
      );
  }
  
  TextEditingController newScale = TextEditingController();
  void _bottomSheet(String grade, double scale) {
    showModalBottomSheet(context: context,
      isScrollControlled: true,
      builder: (BuildContext context,) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  child: const Text("Update Scale", style:TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.mainColor), textAlign: TextAlign.left,)
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Grade : $grade", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    child: SizedBox(
                      width: 80,
                      child: TextField(
                        keyboardType:TextInputType.number,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 3, color: Colors.mainColor)
                          )
                        ),
                        controller: newScale,
                      ),
                    ),
                  )
                ],
              ),

              ElevatedButton(
                onPressed: () {
                print('Click');
                updateScale(grade);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.activeColor
                ),
                child: Container(
                  margin: const EdgeInsets.all(10),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text("Update", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)  )
              )
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () {
            Navigator.of(context).pushNamed("degree");
        },
          ),
          title: const Text("GPA Scale"),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),

          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3, color: Colors.black
                )
              ),
                child: const Row(
                  children: [

                    Expanded(
                      child: Text("Grade", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                    ),

                    Expanded(
                      child: Text("Scale", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                    ),

                    Expanded(
                      child: Text(""),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      children: scaleWidgets,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
