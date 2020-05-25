// Flutter code sample for DropdownButton

// This sample shows a `DropdownButton` with a large arrow icon,
// purple text style, and bold purple underline, whose value is one of "One",
// "Two", "Free", or "Four".
//
// ![](https://flutter.github.io/assets-for-api-docs/assets/material/dropdown_button.png)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyDropDownButton extends StatefulWidget {
  final DocumentReference doc;
  MyDropDownButton(this.doc, {Key key}) : super(key: key);

  @override
  _MyDropDownButtonState createState() => _MyDropDownButtonState(
    doc: this.doc
  );
}

class _MyDropDownButtonState extends State<MyDropDownButton> {
  // String dropdownValue = 'One';
  final DocumentReference doc;

  _MyDropDownButtonState({this.doc});

  @override
  Widget build(BuildContext context) {
    return new DropdownButtonHideUnderline(
 child: DropdownButton<String>(
      // value: dropdownValue,
      icon: Icon(Icons.more_vert),
      // iconSize: 24,
      // elevation: 16,
      // style: TextStyle(color: Colors.black),
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
            print('$value option clicked'),
            if(value == 'Delete'){
              // this.doc.delete(),
            }
          },
        );
      }).toList(),
    )
);
  }
}
