import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  DateTime selectedDate = DateTime.now();
  var mostRecentAlertKey = 0;
  late Timer timer;
  List<String> tableFields = [
    'Hora',
    'Sala',
    'Leitura',
    'Sensor',
    'TipoAlerta',
    'Mensagem',
  ];
  Map<int, List<String>> tableAlerts = {};

  DateTime initTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) => getAlerts());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          /*Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
              const SizedBox(width: 20,),
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () {
                  selectDate(context);
                },
              ),
            ],
          ),*/
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: listFields(),
              rows: listAlerts(),
            ),
          ),
        ],
      ),
    );
  }

  selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(selectedDate.year - 2),
      lastDate: DateTime(selectedDate.year + 2),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
      getAlerts();
    }
  }

  getAlerts() async {
    print("a");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Gets user info back from the login form
    String? username = prefs.getString('username');
    String? ip = prefs.getString('ip');
    String? port = prefs.getString('port');
    String? password = prefs.getString('password');

    //Why create variable if you're not gonna use it?!
    //String date = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

    String alertsURL = "http://" + ip! + ":" + port! + "/db/db_getAlerts.php";

    DateTime currentTime = DateTime.now();
    int secondsAgo = currentTime.difference(initTime).inSeconds;

    var response = await http.post(Uri.parse(alertsURL), body: {'username': username, 'password': password, 'time': secondsAgo.toString()});

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      List<dynamic>? alerts = jsonData["alerts"];

      if (alerts != null && alerts.isNotEmpty) {
        setState(() {
          tableAlerts.clear();
          for (var i = 0; i < alerts.length; i++) {
            Map<String, dynamic> alert = alerts[i];
            int timeKey = int.parse(alert["Hora"].toString().split(" ")[1].replaceAll(":", ""));

            List<String> alertValues = [];
            for (var key in alert.keys) {
              alertValues.add(alert[key] ?? "");
            }
            tableAlerts[timeKey] = alertValues;
          }
        });
      }
    }
  }

  listAlerts() {
    List<DataRow> alertsList = [];
    if (tableAlerts.isEmpty) return alertsList;

    for (int i = tableAlerts.length - 1; i >= 0; i--) {
      int key = tableAlerts.keys.elementAt(i);
      List<DataCell> alertRow = [];
      tableAlerts[key]?.forEach((alertField) {
        if (key > mostRecentAlertKey) {
          alertRow.add(DataCell(
              Text(alertField, style: const TextStyle(color: Colors.blue))));
        } else {
          alertRow.add(DataCell(Text(alertField)));
        }
      });
      alertsList.add(DataRow(cells: alertRow));
    }
    mostRecentAlertKey = tableAlerts.keys.elementAt(tableAlerts.length - 1);
    return alertsList;
  }

  listFields() {
    List<DataColumn> fields = [];
    for (String field in tableFields) {
      fields.add(DataColumn(label: Text(field)));
    }
    return fields;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
