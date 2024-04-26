import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectspace/Mpage3.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Map<String, bool> map = {};

  List<Technology> technologies = [
    Technology('Google Flutter', 'assets/flutter.png'),
    Technology('Dart language', 'assets/dart.png'),
    Technology('JavaScript', 'assets/js.png'),
    Technology('C', 'assets/cLogo.png'),
    Technology('Python', 'assets/pythonLogo.png'),
    Technology('C++', 'assets/cppLogo.png'),
    Technology('Java', 'assets/java.png'),
    Technology('HTML & CSS', 'assets/htmlcssjs.png'),
    Technology('AWS', 'assets/aws.png'),
    Technology('Pega', 'assets/pega.png'),
  ];


  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    int crossAxisCount = (wi > 600) ? 4 : 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Respective Technology'),
          ),
      // backgroundColor: Colors.lightBlue[100],
      body: Stack(
        children: [
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 6.0,
              mainAxisSpacing: 6.0,
            ),
            itemCount: technologies.length,
            itemBuilder: (BuildContext context, int index) {
              return GridTile(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              map[technologies[index].name] = !(map[technologies[index].name] ?? false);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              image: DecorationImage(
                                image: AssetImage(technologies[index].imagePath),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      title: Text(technologies[index].name),
                      value: map[technologies[index].name] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          map[technologies[index].name] = value!;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 5,
              right: 5,
              child:  CupertinoButton(
              color: Colors.blue,
              child: Text("Continue"), onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>Mpage3()));}))
        ],
      ),
    );
  }
}

class Technology {
  final String name;
  final String imagePath;
  Technology(this.name, this.imagePath);
}
