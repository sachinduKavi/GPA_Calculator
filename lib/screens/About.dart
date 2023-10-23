import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("About GPA Calculator"),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Center(child: Image.asset("assets/images/playstore.png", width: 120,)),

              const Text("Version : 1.0.0", style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Color(0xFF747373)),),

              const Padding(padding: EdgeInsets.all(10), child: Text("GPA Calculator", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.activeColor, fontSize: 25),)),

              const Divider(thickness: 2,),

              const Padding(
                padding: EdgeInsets.all(5),
                child: Text("""Our GPA Calculator app, version 1.0.0 is developed to support students' academic journeys. Our aim is to simplify the often-complex task of GPA calculation and management. We understand students' challenges in tracking their grades and staying on top of their academic progress. With our app, we provide a user-friendly solution that allows students to calculate and keep track of their GPA effortlessly. GPA Calculator is here to make your educational experience smoother and more organized. 
This application allows users to calculate semester GPA by adding course modules to each semester separately also you can save your data in the cloud. 
Your final GPA is based on course credits and grades achieved.
Thank you for choosing GPA Calculator, and we hope it proves to be a helpful tool in your academic journey.
"""),
              ),

              const Divider(thickness: 2,),

              const Text("Developed By Sachindu Kavishka", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
              const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text("Designed By Dilsha Himashi", style: TextStyle(fontSize: 12, ),)),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.email),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.resolveWith((states) => 0),
                          foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.mainColor),
                          backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.white)
                        ),
                        onPressed: () async{
                          final Uri url = Uri.parse("mailto:cst21017@std.uwu.ac.lk?subject=Regarding%20GPA%20Calculator");
                          await launchUrl(url);
                    }, label: const Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.account_balance_wallet_rounded),
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.resolveWith((states) => 0),
                            foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.mainColor),
                            backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.white)
                        ),
                        onPressed: () async {
                          final Uri url = Uri.parse("https://www.linkedin.com/in/sachindukavishka7070/");
                          await launchUrl(url);
                        }, label: const Text("Linkedin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
                  ],
                ),
              ),
              
              const Text("All Rights Reserved © 2023")


              

            ],
          ),
        ),
      ),
    );
  }
}
