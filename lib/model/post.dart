import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String uid;
  final String username;
  final String description;
  final String postId;
  final date;
  final String profilePhoto;
  final String postUrl;
  final likes;

  const Post({
    required this.uid,
    required this.username,
    required this.description,
    required this.postId,
    required this.date,
    required this.profilePhoto,
    required this.postUrl,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'description': description,
        'uid': uid,
        'postId': postId,
        'date': date,
        'profilePhoto': profilePhoto,
        'postUrl': postUrl,
        'likes': likes,
      };

  static Post snapToUser(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return Post(
      username: snap['username'],
      description: snap['description'],
      uid: snap['uid'],
      postId: snap['postId'],
      date: snap['date'],
      profilePhoto: snap['profilePhoto'],
      postUrl: snap['postUrl'],
      likes: snap['likes'],
    );
  }
}
