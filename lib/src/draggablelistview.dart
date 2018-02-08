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
  final List<E> source;
  final ItemBuilder<E> builder;
  final OnMoveCallback onMove;

  createState() => new _DraggableListViewState();
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
    var index = 0;
    for (var item in widget.source) {
      _zIndex.add(_buildItem(
        child: widget.builder(item),
        top: top,
        index: index,
      ));
      top = top + widget.rowHeight;
      index++;
    }
  }

  DraggableListViewItem _buildItem(
      {Widget child, double top, int index, Key key}) {
    if (key == null) key = new UniqueKey();
    return new DraggableListViewItem(
      key: key,
      initialTop: top,
      height: widget.rowHeight,
      child: child,
      onDragDown: _drawOnTop,
      onDragIndexChanged: _updatedUndraggedTop,
      onDragEnd: _dragEnd,
    );
  }

  void _drawOnTop(DraggableListViewItem item) {
    setState(() {
      _zIndex.remove(item);
      _zIndex.add(item);
    });
  }

  void _updatedUndraggedTop(double oldTop, double newTop) {
    var undragged =
        _zIndex.firstWhere((element) => element.initialTop == newTop);
    var zInsert = _zIndex.indexOf(undragged);
    var replacement = _buildItem(
      child: undragged.child,
      top: oldTop,
      key: undragged.key,
    );
    setState(() {
      _zIndex.remove(undragged);
      _zIndex.insert(zInsert, replacement);
    });
  }

  void _dragEnd(double oldTop, double newTop) {
    var oldIndex = _topToIndex(oldTop);
    var newIndex = _topToIndex(newTop);
    if (newIndex >= 0 && newIndex < widget.source.length) {
      widget.onMove(oldIndex, newIndex);
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
