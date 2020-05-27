// Flutter code sample for DropdownButton

// This sample shows a `DropdownButton` with a large arrow icon,
// purple text style, and bold purple underline, whose value is one of "One",
// "Two", "Free", or "Four".
//
// ![](https://flutter.github.io/assets-for-api-docs/assets/material/dropdown_button.png)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyDropDownButton extends StatefulWidget {
  final Function updateImagePost;
  MyDropDownButton(this.updateImagePost, {Key key}) : super(key: key);

  @override
  _MyDropDownButtonState createState() => _MyDropDownButtonState(
    updateImagePost: this.updateImagePost
  );
}

class _MyDropDownButtonState extends State<MyDropDownButton> {
  final DocumentReference currentPost;
  final DocumentReference currentFeedItem;
  final Function updateImagePost;
  _MyDropDownButtonState({this.currentPost, this.currentFeedItem, this.updateImagePost});

  @override
  Widget build(BuildContext context) {
    return new DropdownButtonHideUnderline(
     child: DropdownButton<String>(
      icon: Icon(Icons.more_vert),
      onChanged: (String newValue) {
        setState(() {
          // dropdownValue = newValue;
        });
      },
      items: <String>['Edit', 'Delete']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
          onTap: () => {
              widget.updateImagePost(value)
          },
        );
      }).toList(),
    )
);
  }
}
