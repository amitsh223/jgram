import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jgram/models/user.dart';
import 'package:jgram/pages/HomePage.dart';
import 'package:jgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
 // final String timeStamp;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;
 final int likeCount;


  Post(
      {this.url,
      this.postId,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.ownerId,
        this.likeCount
      //this.timeStamp
      });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot.data()['postId'],
      ownerId: documentSnapshot.data()['ownerId'],
      likes: documentSnapshot.data()['likes'],
      username: documentSnapshot.data()['username'],
      description: documentSnapshot.data()['description'],
      location: documentSnapshot.data()['location'],
      url: documentSnapshot.data()['url'],
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) return 0;
    int counter = 0;
    likes.values.forEach((eachValues) {
      if (eachValues == true) {
        counter++;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        likes: this.likes,
        username: this.username,
        location: this.location,
        url: this.url,
        likeCount:getTotalNumberOfLikes(likes),
    description: this.description
      );
}

class _PostState extends State<Post> {

  final String postId;
  final String ownerId;
 // final String timeStamp;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserID = currentUser?.id;

  _PostState(
      {this.url,
      this.postId,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.ownerId,
      this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          createPostHead(),
          postBody(),
          createPostFooter()
        ],
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
        future: usersReference.document(ownerId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapshot.data);
          bool isPostOwner = currentOnlineUserID == ownerId;
          return ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.url),
                backgroundColor: Colors.grey,
              ),
              title: GestureDetector(
                onTap: () => print('show profile'),
                child: Text(
                  user.username,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Text(
                location,
                style: TextStyle(color: Colors.white),
              ),
              trailing: isPostOwner
                  ? IconButton(
                      onPressed: () => print('deleted'),
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    )
                  : Text(''));
        });
  }

  postBody() {
    return GestureDetector(
      onDoubleTap: () => print('post liked'),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(url)
        ],
      ),
    );
  }

  createPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(top: 40, left: 20),
                child: GestureDetector(
                  onTap: () => print('Liked Post'),
                  child: Icon(
                    Icons.favorite
//                    isLiked ? Icons.favorite : Icons.favorite_border,
//                    size: 28,
//                    color: Colors.pink,
                  ),
                )),
            Padding(
                padding: EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () => print('show comments'),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 28,
                    color: Colors.pink,
                  ),
                )),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$likeCount likes',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$username',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                'description',
                style: TextStyle(color: Colors.white),

              ),
            )
          ],
        )
      ],
    );
  }
}
