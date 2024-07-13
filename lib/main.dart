import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tractian/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.home,
      routes: Routes.getRoutes(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF17192D),
        title: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/tractian-2.svg",
            width: 126.0,
              height: 17.0,
              colorFilter: ColorFilter.mode(Color(0XFFF9FAFB), BlendMode.srcIn)
            )
        ],
        )
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 32),
            InkWell(
              onTap: (){
                Navigator.pushNamed(context, Routes.jaguar);
              },
              child: Container(
                width: 317,
                height: 76,
                decoration: ShapeDecoration(
                  color: Color(0XFF2188FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                child: Center(
                  child: ListTile(
                    leading: Image.asset("assets/gold-bar.png", color: Colors.white),
                    title: Text("Jaguar Unit", style: (TextStyle(color: Colors.white, fontSize: 23)),),
                              ),
                ),
                ),
            ),
            SizedBox(height: 32),
            InkWell(
              onTap: (){
                Navigator.pushNamed(context, Routes.tobias);
              },
              child: Container(
                width: 317,
                height: 76,
                decoration: ShapeDecoration(
                  color: Color(0XFF2188FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                child: Center(
                  child: ListTile(
                    leading: Image.asset("assets/gold-bar.png", color: Colors.white),
                    title: Text("Tobias Unit", style: (TextStyle(color: Colors.white, fontSize: 23)),),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            InkWell(
              onTap: (){
                Navigator.pushNamed(context, Routes.apex);
              },
              child: Container(
                width: 317,
                height: 76,
                decoration: ShapeDecoration(
                  color: Color(0XFF2188FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                child: Center(
                  child: ListTile(
                    leading: Image.asset("assets/gold-bar.png", color: Colors.white),
                    title: Text("Apex Unit", style: (TextStyle(color: Colors.white, fontSize: 23)),),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
