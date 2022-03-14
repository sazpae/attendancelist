import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Attendance List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> attendanceStream = FirebaseFirestore.instance
        .collection('attendance')
        .where('student_id', isEqualTo: 'DcCkP1MoNJC86cjSIWLB')
        .snapshots();

    CollectionReference student =
        FirebaseFirestore.instance.collection('students');

    String studentName = "";

    student.doc('DcCkP1MoNJC86cjSIWLB').get().then((value) {
      var studentData = value.data() as Map<String, dynamic>;
      print(studentData['name']);
      studentName = studentData['name'];
    }).catchError((err) => print(err));

    return StreamBuilder<QuerySnapshot>(
        stream: attendanceStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Something Went Wrong');
          }
          if (!snapshot.hasData) {
            print('No Data here');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final List storedocs = [];
          int count = 0;

          snapshot.data!.docs.map((DocumentSnapshot document) {
            Map a = document.data() as Map<String, dynamic>;
            print(a);
            storedocs.add(a);
            if (a['is_present'].toString() == 'true') {
              count++;
            }
            a['id'] = document.id;
          }).toList();

          print(count);

          return Scaffold(
            appBar: AppBar(
              title: Text(studentName),
            ),
            body: Center(
              child: Table(
                border: TableBorder.all(),
                children: [
                  buildRow(['DATE', 'PRESENT'], isHeader: true),
                  for (var i = 0; i < storedocs.length; i++) ...[
                    buildRow([
                      storedocs[i]['date'].toString(),
                      storedocs[i]['is_present'].toString()
                    ]),
                  ]
                ],
              ),
            ),
          );
        });
  }

  buildRow(List<String> cells, {bool isHeader = false}) => TableRow(
        children: cells.map((cell) {
          final style = TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: 18,
          );
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Center(child: Text(cell)),
          );
        }).toList(),
      );
}
