import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:draggablelistview/draggablelistview.dart';

void main() {
  testWidgets("Render basic list", (WidgetTester tester) async {
    var source = [
      "A",
      "B",
      "C",
    ];
    Key listKey = new UniqueKey();

    await tester.pumpWidget(
      new MaterialApp(
        home: new Container(
          width: 100.0,
          height: 300.0,
          child: new DraggableListView<String>(
            onMove: (oldIndex,newIndex)=>{},
              key: listKey,
              rowHeight: 50.0,
              source: source,
              builder: (value) {
                return new Text(value);
              },
          ),
        )
      )
    );

    expect(tester.getCenter(find.text("A")).dy, equals(25));
    expect(tester.getCenter(find.text("B")).dy, equals(75));
    expect(tester.getCenter(find.text("C")).dy, equals(125));
  });
}
