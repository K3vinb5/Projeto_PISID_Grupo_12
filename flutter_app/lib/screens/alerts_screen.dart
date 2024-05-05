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
  late Timer timer;
  DateTime selectedDate = DateTime.now();
  var mostRecentAlertKey = 0;

  List<String> tableFields = [
    'Mensagem',
    'Leitura',
    'Sala',
    'Sensor',
    'TipoAlerta',
    'Hora',
    'HoraEscrita'
  ];
  Map<int, List<String>> tableAlerts = {};

  @override
  void initState() {
    super.initState();
    const oneSec = Duration(seconds: 1);
    //timer = Timer.periodic(oneSec, (Timer t) => getAlerts());
    //TODO fix screen (depends on previous script)
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          Row(
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
          ),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Gets user info back from the login form
    String? username = prefs.getString('username');
    String? ip = prefs.getString('ip');
    String? port = prefs.getString('port');
    String? password = prefs.getString('password');

    //Why create variable if you're not gonna use it?!
    //String date = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

    String alertsURL = "http://" + ip! + ":" + port! + "/db/db_getAlerts.php";

    var response = await http.post(Uri.parse(alertsURL),
        body: {'username': username, 'password': password});

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      var alerts = jsonData["alerts"];
      if (alerts != null && alerts.length > 0) {
        setState(() {
          tableAlerts.clear();
          for (var i = 0; i < alerts.length; i++) {
            Map<String, dynamic> alert = alerts[i];
            int timeKey = int.parse(
                alert["Hora"].toString().split(" ")[1].replaceAll(":", ""));
            var alertValues = <String>[];
            for (var key in alert.keys) {
              if (alert[key] == null) {
                alertValues.add("");
              } else {
                alertValues.add(alert[key]);
              }
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
