import 'package:flutter/material.dart';
import 'package:draggablelistview/draggablelistview.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Demo Draggable ListView'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> data = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];

  int _currentCounter = 11;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new DraggableListView<String>(
              source: data,
              rowHeight: 48.0,
              onMove: moveItem,
              builder: (String value) => new Align(
                    alignment: Alignment.centerLeft,
                    child: new Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: new Text(value),
                    ),
                  ),
            ),
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                child: new RaisedButton(
                  onPressed: addItem,
                  child: new Text("Add $_currentCounter"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void moveItem(int oldIndex, int newIndex) {
    data.insert(newIndex, data.removeAt(oldIndex));
  }

  void addItem(){
    setState(() {
      data.add(_currentCounter.toString());
      _currentCounter++;
    });
  }
}
