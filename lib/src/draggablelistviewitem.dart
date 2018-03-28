import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

typedef void MoveItemCallback(int oldIndex);
typedef void DragDownCallback(DraggableListViewItem item);
typedef void DragEndCallback(double oldTop, double newTop);
typedef void DragIndexChangedCallback(double oldTop, double newTop);
typedef void DragCallback();

class DraggableListViewItem extends StatefulWidget {
  DraggableListViewItem({
    Key key,
    @required this.initialTop,
    @required this.height,
    @required this.child,
    @required this.onDragDown,
    @required this.onDragIndexChanged,
    @required this.onDragEnd,
    @required this.onDraggedToTop,
    @required this.onDraggedToBottom,
    @required this.onEdgeDragStopped,
    @required this.listScrollController,
  })
      : super(key: key);

  final double initialTop;
  final double height;
  final Widget child;
  final DragDownCallback onDragDown;
  final DragIndexChangedCallback onDragIndexChanged;
  final DragEndCallback onDragEnd;
  final DragCallback onDraggedToTop;
  final DragCallback onDraggedToBottom;
  final DragCallback onEdgeDragStopped;
  final ScrollController listScrollController;

  createState() => new _DraggableListViewItemState(initialTop);
}

class _DraggableListViewItemState extends State<DraggableListViewItem> {
  _DraggableListViewItemState(double initialTop) {
    _initialTop = initialTop;
    _currentTop = initialTop;
    _currentSnapTop = initialTop;
    _priorSnapTop = initialTop;
  }

  double _elevation = 0.0;
  double _initialTop;
  double _currentTop;
  double _currentSnapTop;
  double _priorSnapTop;
  int _animateTime = _defaultAnimateTime;
  double _listBottom;
  double _listTop;
  static const int _defaultAnimateTime = 200;

  void _dragDown(DragDownDetails details) {
    double stackHeight;
    double scrollViewHeight;

    // Get the size of the list viewport area
    context.visitAncestorElements((element) {
      if (element.widget is Stack) {
        stackHeight = element.size.height;
        return true;
      } else if (element.widget is SingleChildScrollView) {
        _listTop = widget.listScrollController.offset;
        scrollViewHeight = element.size.height;

        if (scrollViewHeight < stackHeight) {
          _listBottom = scrollViewHeight + _listTop;
        } else {
          _listBottom = stackHeight + _listTop;
        }

        _animateTime = 0;
        _setMovingElevation();
        widget.onDragDown(widget);
        return false;
      } else {
        return true;
      }
    });
  }

  void _dragUpdate(DragUpdateDetails details) {
    var newTop = _getConstrainedTop(details.delta.dy);
    _setCurrentSnapTop(newTop);
    setState(() => _currentTop = newTop);
  }

  double _getConstrainedTop(double change) {
    var newTop = _currentTop + change;
    var newBottom = newTop + widget.height;

    if (newBottom > _listBottom) newTop = _listBottom - widget.height;

    if (newTop < _listTop) newTop = _listTop;

    return newTop;
  }

  Future _dragEnd(DragEndDetails details) async {
    _animateTime = _defaultAnimateTime;
    _currentTop = _currentSnapTop;
    _setRestElevation();
    await new Future.delayed(const Duration(milliseconds: _defaultAnimateTime));
    widget.onDragEnd(_initialTop, _currentTop);
  }

  void _dragCancel() {
    _animateTime = _defaultAnimateTime;
    _currentTop = _initialTop;
    _setRestElevation();
  }

  void _setCurrentSnapTop(double newTop) {
    double snapChange = _getSnapChange(newTop);
    if (snapChange != 0) {
      _priorSnapTop = _currentSnapTop;
      _currentSnapTop += snapChange;
      widget.onDragIndexChanged(_priorSnapTop, _currentSnapTop);
    }
  }

  double _getSnapChange(double top) {
    double diffToSnapTop = top - _currentSnapTop;
    double threshold = widget.height / 2;
    return (diffToSnapTop ~/ threshold) * widget.height;
  }

  void _setMovingElevation() {
    setState(() {
      _elevation = 2.0;
    });
  }

  void _setRestElevation() {
    setState(() {
      _elevation = 0.0;
    });
  }

  build(BuildContext context) {
    if (_initialTop != widget.initialTop) {
      _initialTop = widget.initialTop;
      _currentSnapTop = _initialTop;
      _currentTop = _initialTop;
    }

    return new AnimatedPositioned(
      top: _currentTop,
      height: widget.height,
      duration: new Duration(milliseconds: _animateTime),
      left: 0.0,
      right: 0.0,
      child: new Material(
        elevation: _elevation,
        child: new Row(
          children: <Widget>[
            new Expanded(child: widget.child),
            new GestureDetector(
              onVerticalDragDown: _dragDown,
              onVerticalDragUpdate: _dragUpdate,
              onVerticalDragEnd: _dragEnd,
              onVerticalDragCancel: _dragCancel,
              child: new Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: new Icon(Icons.drag_handle)),
            ),
          ],
        ),
      ),
    );
  }
}
