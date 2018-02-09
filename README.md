# DraggableListView

A Flutter widget to render a list with drag-and-drop capabilities.  Conceptually, the design borrows a lot from [orderable_stack](https://github.com/rxlabz/orderable_stack).

The list is rendered in a Stack widget that is nested inside a SingleChildScrollView.  The contents of the entire list are built at once, so this version may not be performant for larger lists.

### Example

See the Example folder.

<img src="https://storage.googleapis.com/www.porcupinesupernova.com/images/DraggableListView.gif" width=300/>

### Usage

```
List<String> data = ['A','B','C'];

Widget build(BuildContext context) {
  return new DraggableListView<String>(
    source: data,
    rowHeight: 48.0,
    onMove: (oldIndex, newIndex) => data.insert(newIndex, data.removeAt(oldIndex)),
    builder: (value) => new Text(value),
  );
}
```

The following parameters are required:
* source: A List of items of the specified type of data.  E.g. `List<String>` or `List<MyCustomClass>`
* rowHeight: Specifies the height of each row in the list.  All rows are forced to this height.
* onMove: A callback which is called when an item is dropped after being dragged.  The callback is provided the original index of the dragged item and the new index where the item was dropped.  It is called after the drop animation is performed.  Once this callback finishes, the entire DraggableListView is re-built from the (presumably) modified source data.
* builder: A builder method to provide the content of each row of data.  The builder method is provided a typed object from the source list.  A source of `List<String>` will call builder with a String while a source of `List<MyCustomClass>` will call builder with a MyCustomClass.  Most of the content of the list item is provided by this method.  The only content added to each item in the DraggableListView is a drag handle placed on the right side of each item.

### Features and to-do

The features which have been implemented are:
* The list can scroll
* Calling setState on the parent widget after adding or removing items will cause DraggableListItem to correctly rebuild.
* Items can be dragged and dropped with appropriate animations

The features still to be implemented are:
* Currently every item in the source is built when DraggableListView is created.  Looking to possibly lazy load or sliver the rows so DraggableListView is more performant with large lists.
* Auto-scroll DraggableListView up and down when items are dragged to the top and bottom of the rendered viewport.
* Create widget tests to define, and prevent regression of, expected behaviors
* The DragUpdate process throws exceptions when an item is dragged completely off the list.  Need to investigate further.
