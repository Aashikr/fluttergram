import 'dart:html';
import 'dart:io';

import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart'; //for currentuser & google signin instance
import 'models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  Future getImage(ImageSource source) async {

  }

      changeProfilePhoto(BuildContext parentContext) {
        return showDialog(
          context: parentContext,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Change Photo'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                        'Changing your profile photo has not been implemented yet'),
                  ],
                ),
              ),
            );
          },
        );
      }
    
      applyChanges() {
        Firestore.instance
            .collection('insta_users')
            .document(currentUserModel.id)
            .updateData({
          "displayName": nameController.text,
          "bio": bioController.text,
        });
      }
    
      Widget buildTextField({String name, TextEditingController controller}) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                name,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: name,
              ),
            ),
          ],
        );
      }
    
      @override
      Widget build(BuildContext context) {
        return FutureBuilder(
            future: Firestore.instance
                .collection('insta_users')
                .document(currentUserModel.id)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Container(
                    alignment: FractionalOffset.center,
                    child: CircularProgressIndicator());
    
              User user = User.fromDocument(snapshot.data);
    
              nameController.text = user.displayName;
              bioController.text = user.bio;
    
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(currentUserModel.photoUrl),
                      radius: 50.0,
                    ),
                  ),
                  FlatButton(
                      onPressed: () {{
                                    showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) {
                                          return Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(16),
                                                  topRight:
                                                      Radius.circular(16)),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Container(
                                                  width: 80,
                                                  height: 7,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Color(0XFFeeedee),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(5)),
                                                ),
                                                SizedBox(height: 20),
                                                Container(
                                                  width: double.infinity,
                                                  child: OutlineButton(
                                                    padding:
                                                        EdgeInsets.all(16),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Colors.black45),
                                                    child:
                                                        Text('Take a photo'),
                                                    onPressed: () {
                                                      getImage(
                                                          ImageSource.camera);
                                                    },
                                                  ),
                                                ),
                                                SizedBox(height: 16),
                                                Container(
                                                  width: double.infinity,
                                                  child: OutlineButton(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Colors.black45),
                                                    padding:
                                                        EdgeInsets.all(16),
                                                    child: Text(
                                                        'Choose from gallery'),
                                                    onPressed: () {
                                                      getImage(ImageSource
                                                          .gallery);
                                                    },
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                              ],
                                            ),
                                          );
                                        });
                      },
                      child: Text(
                        "Change Photo",
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        buildTextField(name: "Name", controller: nameController),
                        buildTextField(name: "Bio", controller: bioController),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MaterialButton(
                        onPressed: () => {_logout(context)},
                        child: Text("Logout")
    
                    )
                  )
                ],
              );
            });
      }
    
      void _logout(BuildContext context) async {
        print("logout");
        await auth.signOut();
        await googleSignIn.signOut();
    
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
    
        currentUserModel = null;
    
        Navigator.pop(context);
      }
    }
    
    class StorageReference {
}
