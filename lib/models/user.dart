import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String profileName;
  final String username;
  final String url;
  final String email;
  final String bio;

  User({
    this.id,
    this.profileName,
    this.username,
    this.url,
    this.email,
    this.bio,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      email: doc.data()['email'],
      username: doc.data()['username'],
      url: doc.data()['url'],
      profileName: doc.data()['profileName'],
      bio: doc.data()['bio'],
    );
  }
}