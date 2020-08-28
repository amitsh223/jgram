import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jgram/models/user.dart';
import 'package:jgram/pages/CreateAccountPage.dart';
import 'package:jgram/pages/NotificationsPage.dart';
import 'package:jgram/pages/ProfilePage.dart';
import 'package:jgram/pages/SearchPage.dart';
import 'package:jgram/pages/TimeLinePage.dart';
import 'package:jgram/pages/UploadPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection("users");
User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;
  final DateTime timeStamp=DateTime.now();

  void initState() {
    pageController = PageController();
    super.initState();
    gSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }, onError: (gError) {
      print(gError);
    });
    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }).catchError((gError) {
      print(gError);
    });
  }

  loginUser() {
    gSignIn.signIn();
  }

  logOutUser() {
    gSignIn.signOut();
  }

  controlSignIn(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      await saveUserToFirebase();
      setState(() {
        isSignedIn = true;
      });
    } else {
      setState(() {
        isSignedIn = false;
      });
    }
  }

  saveUserToFirebase() async {
    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot =
        await usersReference.document(gCurrentUser.id).get();
    if (!documentSnapshot.exists) {
      final username = await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => CreateAccountPage()));
      usersReference.document(gCurrentUser.id).setData({
        "id":gCurrentUser.id,
        "profileName":gCurrentUser.displayName,
        "username":username,
        "url":gCurrentUser.photoUrl,
        "email":gCurrentUser.email,
        "bio":"",
        "timeStamp":timeStamp,
      });
    documentSnapshot=await usersReference.document(gCurrentUser.id).get();
    }
    currentUser=User.fromDocument(documentSnapshot);


  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  Widget buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: [
          Scaffold(body: RaisedButton(onPressed: logOutUser,child: Text('signout'),),),
          SearchPage(),
          UploadPage(),
          NotificationsPage(),
          ProfilePage()
        ] ,
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: whenPageChanges,
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        activeColor: Colors.white,
        inactiveColor: Colors.blueGrey,
        backgroundColor: Theme.of(context).accentColor,
        onTap: onTapChangePage,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 37,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person))
        ],
      ),
    );
  }

  Widget buildSignedInScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.black, Colors.grey, Colors.grey]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Text(
              'J Gram',
              style: GoogleFonts.rye(fontSize: 92, color: Colors.white),
            )),
            GestureDetector(
              onTap: () => loginUser(),
              child: Container(
                width: 270,
                height: 65,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/google_signin_button.png"))),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignedInScreen();
    }
  }
}
