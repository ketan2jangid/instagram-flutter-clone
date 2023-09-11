import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String email;
  final String uid;
  final String bio;
  final String photo;
  final List followers;
  final List following;

  const User({
    required this.username,
    required this.email,
    required this.uid,
    required this.bio,
    required this.photo,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'uid': uid,
        'bio': bio,
        'photo': photo,
        'followers': followers,
        'following': following,
      };

  static User snapToUser(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return User(
      username: snap['username'],
      email: snap['email'],
      uid: snap['uid'],
      bio: snap['bio'],
      photo: snap['photo'],
      followers: snap['followers'],
      following: snap['following'],
    );
  }
}
