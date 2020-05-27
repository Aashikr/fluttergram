import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main.dart';
import 'dart:async';
import 'profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'comment_screen.dart';
import 'dropdown_button.dart';
import 'package:flare_flutter/flare_actor.dart';

class ImagePost extends StatefulWidget {
  const ImagePost(
      {this.mediaUrl,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.postId,
      this.ownerId,
      this.timestamp});

  factory ImagePost.fromDocument(DocumentSnapshot document) {
    return ImagePost(
      username: document['username'],
      location: document['location'],
      mediaUrl: document['mediaUrl'],
      likes: document['likes'],
      description: document['description'],
      postId: document.documentID,
      ownerId: document['ownerId'],
      timestamp: document['timestamp'],
    );
  }

  factory ImagePost.fromJSON(Map data) {
    return ImagePost(
      username: data['username'],
      location: data['location'],
      mediaUrl: data['mediaUrl'],
      likes: data['likes'],
      description: data['description'],
      ownerId: data['ownerId'],
      postId: data['postId'],
      timestamp: data['timestamp']
    );
  }

  int getLikeCount(var likes) {
    if (likes == null) {
      return 0;
    }
// issue is below
    var vals = likes.values;
    int count = 0;
    for (var val in vals) {
      if (val == true) {
        count = count + 1;
      }
    }

    return count;
  }

  final String mediaUrl;
  final String username;
  final String location;
  final String description;
  final likes;
  final String postId;
  final String ownerId;
  final String timestamp;

  _ImagePost createState() => _ImagePost(
        mediaUrl: this.mediaUrl,
        username: this.username,
        location: this.location,
        description: this.description,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        ownerId: this.ownerId,
        postId: this.postId,
        timestamp: this.timestamp,
      );
}

class _ImagePost extends State<ImagePost> {
  final String mediaUrl;
  final String username;
  final String location;
  String description;
  final String timestamp;
  Map likes;
  int likeCount;
  final String postId;
  bool liked;
  final String ownerId;

  bool showHeart = false;

  TextStyle boldStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  var reference = Firestore.instance.collection('insta_posts');

  _ImagePost(
      {this.mediaUrl,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.postId,
      this.likeCount,
      this.ownerId,
      this.timestamp});

  GestureDetector buildLikeIcon() {
    Color color;
    IconData icon;

    if (liked) {
      color = Colors.pink;
      icon = FontAwesomeIcons.solidHeart;
    } else {
      icon = FontAwesomeIcons.heart;
    }

    return GestureDetector(
        child: Icon(
          icon,
          size: 25.0,
          color: color,
        ),
        onTap: () {
          _likePost(postId);
        });
  }

  GestureDetector buildLikeableImage() {
    return GestureDetector(
      onDoubleTap: () => _likePost(postId),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.fitWidth,
            placeholder: (context, url) => loadingPlaceHolder,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          showHeart
              ? Positioned(
                  child: Container(
                    width: 100,
                    height: 100,
                    child:  Opacity(
                        opacity: 0.85,
                        child: FlareActor("assets/flare/Like.flr",
                          animation: "Like",
                        )),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  buildPostHeader({String ownerId}) {
    if (ownerId == null) {
      return Text("owner error");
    }

    return FutureBuilder(
        future: Firestore.instance
            .collection('insta_users')
            .document(ownerId)
            .get(),
        builder: (context, snapshot) {

          if (snapshot.data != null) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(snapshot.data.data['photoUrl']),
                backgroundColor: Colors.grey,
              ),
              title: GestureDetector(
                child: Text(snapshot.data.data['username'], style: boldStyle),
                onTap: () {
                  openProfile(context, ownerId);
                },
              ),
              subtitle: Text(this.location),
              trailing: GestureDetector(
                // child: Icon(Icons.more_vert),
                child: buildDropdownButton(),
              )
            );
          }

          // snapshot data is null here
          return Container();
        });
  }

  buildDropdownButton() {
    return MyDropDownButton(_updateImagePost);
  }

  Container loadingPlaceHolder = Container(
    height: 400.0,
    child: Center(child: CircularProgressIndicator()),
  );

  

  @override
  Widget build(BuildContext context) {
    liked = (likes[googleSignIn.currentUser.id.toString()] == true);
    var displayTimeStamp = calculateTimestamp(timestamp);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildPostHeader(ownerId: ownerId),
            buildLikeableImage(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
                buildLikeIcon(),
                Padding(padding: const EdgeInsets.only(right: 20.0)),
                GestureDetector(
                    child: const Icon(
                      FontAwesomeIcons.comment,
                      size: 25.0,
                    ),
                    onTap: () {
                      goToComments(
                          context: context,
                          postId: postId,
                          ownerId: ownerId,
                          mediaUrl: mediaUrl);
                    }),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "$likeCount likes",
                    style: boldStyle,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "$username ",
                      style: boldStyle,
                    )),
                Expanded(child: Text(description)),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "$displayTimeStamp ",
                    // style: boldStyle,
                  ),
                ),
              ],
            ),
          ],
        );
      }

      void _updateImagePost(String action){
        var currentPost = Firestore.instance
            .collection('insta_posts')
            .document(postId);
        if(action == 'Edit'){
            currentPost.updateData({
                "description": 'Edited description'
            });
          setState(() {
            description = 'Edited description';
          });
        } else if(action == 'Delete') {
         currentPost.updateData({
                "description": ''
            });
          setState(() {
            description = '';
          });
        }
      }
    
      void _likePost(String postId2) {
        var userId = googleSignIn.currentUser.id;
        bool _liked = likes[userId] == true;
    
        if (_liked) {
          print('removing like');
          reference.document(postId).updateData({
            'likes.$userId': false
            //firestore plugin doesnt support deleting, so it must be nulled / falsed
          });
    
          setState(() {
            likeCount = likeCount - 1;
            liked = false;
            likes[userId] = false;
          });
    
          removeActivityFeedItem();
        }
    
        if (!_liked) {
          print('liking');
          reference.document(postId).updateData({'likes.$userId': true});
    
          addActivityFeedItem();
    
          setState(() {
            likeCount = likeCount + 1;
            liked = true;
            likes[userId] = true;
            showHeart = true;
          });
          Timer(const Duration(milliseconds: 2000), () {
            setState(() {
              showHeart = false;
            });
          });
        }
      }
    
      void addActivityFeedItem() {
        Firestore.instance
            .collection("insta_a_feed")
            .document(ownerId)
            .collection("items")
            .document(postId)
            .setData({
          "username": currentUserModel.username,
          "userId": currentUserModel.id,
          "type": "like",
          "userProfileImg": currentUserModel.photoUrl,
          "mediaUrl": mediaUrl,
          "timestamp": DateTime.now(),
          "postId": postId,
        });
      }
    
      void removeActivityFeedItem() {
        Firestore.instance
            .collection("insta_a_feed")
            .document(ownerId)
            .collection("items")
            .document(postId)
            .delete();
      }
    }
    
    calculateTimestamp(timestamp) {
    var now = DateTime.now();
    var postTime = DateTime.parse(timestamp);
    var difference = now.difference(postTime);
    var dayDiff = difference.inDays;
    var minDiff = difference.inMinutes;
    var hourDiff = difference.inHours;
    var secDiff = difference.inSeconds;
    var displayTimestamp = '$secDiff seconds ago';
    if(secDiff >= 60 ){
      displayTimestamp = minDiff > 1 ? '$minDiff minutes ago': '$minDiff minute ago';
    }
    if(minDiff >= 60) {
      displayTimestamp = hourDiff > 1 ? '$hourDiff hours ago': '$hourDiff hour ago';
    }
    if(hourDiff >= 24) {
      displayTimestamp = dayDiff > 1? '$dayDiff days ago': '$dayDiff day ago';
    }
    return displayTimestamp;
}

class ImagePostFromId extends StatelessWidget {
  final String id;

  const ImagePostFromId({this.id});

  getImagePost() async {
    var document =
        await Firestore.instance.collection('insta_posts').document(id).get();
    return ImagePost.fromDocument(document);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getImagePost(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                padding: const EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator());
          return snapshot.data;
        });
  }
}

void goToComments(
    {BuildContext context, String postId, String ownerId, String mediaUrl}) {
  Navigator.of(context)
      .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
    return CommentScreen(
      postId: postId,
      postOwner: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
