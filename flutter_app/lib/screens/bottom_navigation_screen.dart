import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({Key? key, required this.navigationShell}) : super(key: key);

  final StatefulNavigationShell navigationShell;


  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {

  int selectedIndex = 0;
  List<String> appBarTitle = ["Alerts", "Mice / Rooms", "Sensor 1", "Sensor 2"];

  void onBottomNavigationBarTap(/*BuildContext context, */int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle[selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
            iconSize:30,
            selectedFontSize:16,
            unselectedFontSize:16,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon:Icon(Icons.crisis_alert),
                label:'Alerts',
                backgroundColor:Colors.blue,
              ),
              BottomNavigationBarItem(
                icon:Icon(Icons.gesture),
                label:'Mice/Room',
                backgroundColor:Colors.blue,
              ),
              BottomNavigationBarItem(
                icon:Icon(Icons.sensors),
                label:'Temp Sensor 1',
                backgroundColor:Colors.blue,
              ),
              BottomNavigationBarItem(
                icon:Icon(Icons.sensors),
                //<ion-icon name="thermometer-outline"></ion-icon>
                label:'Temp Sensor 2',
                backgroundColor:Colors.blue,
              ),
            ],
            type: BottomNavigationBarType.shifting,
            currentIndex: selectedIndex,
            selectedItemColor: Colors.black,
            //iconSize: 40,
            onTap: onBottomNavigationBarTap,
            elevation: 5
        )
    );
  }
}
