import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:draggablelistview/src/draggablelistviewitem.dart';

/// Tells [DraggableListView] how to build a data item.
typedef Widget ItemBuilder<E>(E item);

/// Called by [DraggableListView] when an item is dropped onto a new position.
typedef void OnMoveCallback(int oldIndex, int newIndex);

/// A widget that displays a list of items with the ability to perform
/// drag-and-drop reordering.
///
/// The following parameters are required:
/// * [rowHeight] specifies the fixed height of each row
/// * [source] is the list of data items to be rendered
/// * [builder] is an [ItemBuilder] which builds the content of the row.
/// * [onMove] is an [OnMoveCallback] which allows the parent object
///   to handle re-order changes to the source data.
class DraggableListView<E> extends StatefulWidget {
  DraggableListView({
    Key key,

    /// Identifies the height of each row.  All rows are forced to same height.
    @required this.rowHeight,

    /// Identifies a list of data items which [DraggableListView] should render.
    @required this.source,

    /// A builder method which builds a Widget that graphically represents an
    /// item in the [DraggableListView].
    @required this.builder,

    /// A [OnMoveCallback] which fires when an item is dragged and dropped onto
    /// a new location.
    ///
    /// The [DraggableListView] performs all of the layout to place the existing
    /// widget into its new location, then calls this callback.  It is expected
    /// the change will be properly handled back to the source data.  Once this
    /// callback finishes the [DraggableListView] will rebuild itself from the
    /// updated data.
    @required this.onMove,
  })
      : super(key: key);

  final double rowHeight;
  final Iterable<E> source;
  final ItemBuilder<E> builder;
  final OnMoveCallback onMove;

  createState() => new _DraggableListViewState<E>();
}

class _DraggableListViewState<E> extends State<DraggableListView<E>> {
  _DraggableListViewState();

  var _zIndex = new List<DraggableListViewItem>();

  initState() {
    super.initState();
    _buildItems();
  }

  void _buildItems() {
    _zIndex.clear();
    var top = 0.0;
    for (var item in widget.source) {
      _zIndex.add(_buildItem(
        child: widget.builder(item),
        top: top,
      ));
      top += widget.rowHeight;
    }
  }

  DraggableListViewItem _buildItem(
      {Widget child, double top, Key key}) {
    if (key == null) key = new UniqueKey();
    return new DraggableListViewItem(
      key: key,
      initialTop: top,
      height: widget.rowHeight,
      child: child,
      onDragDown: _drawOnTop,
      onDragIndexChanged: _updateUndraggedTops,
      onDragEnd: _dragEnd,
    );
  }

  void _drawOnTop(DraggableListViewItem item) {
    setState(() {
      _zIndex.remove(item);
      _zIndex.add(item);
    });
  }

  // In normal circumstances we could simply swap the top of the undragged widget
  // with the oldTop provided here by the dragged widget.  However, if the user
  // drags quickly enough the [onDragIndexChanged] callback may not fire until
  // the dragging widget has travelled far enough to move 2 or more places in the
  // list.  Hence, we need to use the process here to iterate through all of the
  // undragged widgets affected by the change in position and update all of their
  // tops appropriately.
  void _updateUndraggedTops(double oldTop, double newTop) {
    if (newTop > oldTop){
      _moveUndraggedUp(oldTop, newTop);
    } else {
      _moveUndraggedDown(oldTop, newTop);
    }
    setState((){});
  }

  void _moveUndraggedUp(double oldTop, double newTop){
    double current = oldTop + widget.rowHeight;
    for (;current <= newTop;current += widget.rowHeight ){
      var undragged =
      _zIndex.firstWhere((element) => element.initialTop == current);
      var replacement = _buildItem(
        child: undragged.child,
        top: current - widget.rowHeight,
        key: undragged.key,
      );
      var zInsertIndex = _zIndex.indexOf(undragged);
      _zIndex.remove(undragged);
      _zIndex.insert(zInsertIndex, replacement);
    }
  }

  void _moveUndraggedDown(double oldTop, double newTop){
    double current = oldTop - widget.rowHeight;
    for (;current >= newTop;current -= widget.rowHeight ){
      var undragged =
      _zIndex.firstWhere((element) => element.initialTop == current);
      var replacement = _buildItem(
        child: undragged.child,
        top: current + widget.rowHeight,
        key: undragged.key,
      );
      var zInsertIndex = _zIndex.indexOf(undragged);
      _zIndex.remove(undragged);
      _zIndex.insert(zInsertIndex, replacement);
    }
  }

  Future _dragEnd(double oldTop, double newTop) async {
    var oldIndex = _topToIndex(oldTop);
    var newIndex = _topToIndex(newTop);
    if (newIndex >= 0 && newIndex < widget.source.length) {
      await new Future(() => widget.onMove(oldIndex, newIndex));
    }
    setState(_buildItems);
  }

  int _topToIndex(double top) {
    return top ~/ widget.rowHeight;
  }

  Widget build(BuildContext context) {
    var height = widget.rowHeight * widget.source.length;
    if (_zIndex.length != widget.source.length) _buildItems();

    return new Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: new SingleChildScrollView(
        child: new Container(
          height: height,
          child: new Stack(
            children: _zIndex,
          ),
        ),
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );
  }
}
