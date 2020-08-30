import 'package:flutter/material.dart';
import 'package:jgram/models/user.dart';
import 'package:jgram/pages/EditProfilePage.dart';
import 'package:jgram/pages/HomePage.dart';
import 'package:jgram/widgets/Header.dart';
import 'package:jgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;

  createProfileTopView() {
    return FutureBuilder(
        future: usersReference.document(widget.userProfileId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) return circularProgress();
          User user = User.fromDocument(dataSnapshot.data);
          return Padding(
            padding: EdgeInsets.all(17),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(user.url),
                      radius: 45,
                      backgroundColor: Colors.grey,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createColumns("Posts", 0),
                              createColumns("Followers", 0),
                              createColumns("Following", 0),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [createButton()],
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 13),
                  child: Text(
                    user.username,
                    style: TextStyle(fontSize: 14.0, color: Colors.white),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    user.profileName,
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3),
                  child: Text(
                    user.bio,
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        });
  }

  createColumns(String title, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w300),
          ),
        )
      ],
    );
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createTitleAndFunction(
          title: "Edit Profile", performFunction: editUserProfile);
    }
  }

  createTitleAndFunction({String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3),
      child: FlatButton(
        onPressed: editUserProfile,
        child: Container(
          width: 245,
          height: 26.0,
          child: Text(
            title,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfilePage(
                  currentOnlineUserId: widget.userProfileId,
                ))).then((value) {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, title: 'Profile'),
        body: ListView(
          children: [createProfileTopView()],
        ));
  }
}
