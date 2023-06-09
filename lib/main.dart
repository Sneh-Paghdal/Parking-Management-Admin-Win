import 'package:flutter/material.dart';
import 'package:parkingadmin/screens/booking_screen.dart';
import 'package:parkingadmin/screens/ev_screen.dart';
import 'package:parkingadmin/screens/map_screen.dart';
import 'package:parkingadmin/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autospot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "autoSpotSP",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routes: {
        '/Myhome_page': (context) => MyHomePage(selectedIndex: 0),
        '/map_screen': (context) => map_screen(),
        '/booking_screen': (context) => booking_screen(),
        '/ev_screen': (context) => ev_screen(),
      },
      // home: MyHomePage(selectedIndex: 0,),
      home: splash_screen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  int selectedIndex = 0;
  MyHomePage({super.key, required this.selectedIndex});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Widget> _widgetOptions = [
    map_screen(),
    booking_screen(),
    ev_screen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          backgroundColor: Colors.black87,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.map,color: Colors.yellow,),
                    title: Text('Map',style: TextStyle(color: Colors.white),),
                    onTap: () {
                      setState(() {
                        widget.selectedIndex = 0;
                      });
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.book_outlined,color: Colors.yellow,),
                    title: Text('Booking',style: TextStyle(color: Colors.white),),
                    onTap: () {
                      setState(() {
                        widget.selectedIndex = 1;
                      });
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.ev_station_outlined,color: Colors.yellow,),
                    title: Text('EV',style: TextStyle(color: Colors.white),),
                    onTap: () {
                      setState(() {
                        widget.selectedIndex = 2;
                      });
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Text("Developed for GTU DE project",style: TextStyle(color: Colors.yellow.shade200),),
              )
            ],
          ),
        ),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
        title: Text((widget.selectedIndex == 0) ? "Autospot (Offline Map)" : (widget.selectedIndex == 1) ? "Autospot (Online Booking)" : "Autospot (EV Booking)",style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _widgetOptions.elementAt(widget.selectedIndex),
          ],
        ),
      )
    );
  }
}
