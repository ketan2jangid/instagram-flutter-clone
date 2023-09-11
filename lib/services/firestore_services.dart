import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/model/post.dart';
import 'package:instagram_clone/services/storage_services.dart';
import 'package:uuid/uuid.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future uploadPost({
    required String username,
    required String uid,
    required Uint8List img,
    required String description,
    required String profileImage,
  }) async {
    String result = "Some error occurred";

    try {
      String photoUrl = await StorageServices()
          .uploadImage(file: img, folder: 'posts', isPost: true);

      String postId = const Uuid().v1();
      Post post = Post(
        uid: uid,
        username: username,
        description: description,
        postId: postId,
        date: DateTime.now(),
        profilePhoto: profileImage,
        postUrl: photoUrl,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());

      result = "success";
    } catch (err) {
      result = err.toString();
    }

    return result;
  }

  Future likePost({
    required String postId,
    required String uid,
    required List likes,
  }) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future postComment({
    required String postId,
    required String uid,
    required String name,
    required String profileImg,
    required String commentText,
  }) async {
    try {
      if (commentText.isNotEmpty) {
        String commentId = Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'name': name,
          'uid': uid,
          'profileImg': profileImg,
          'commentId': commentId,
          'commentText': commentText,
          'datePublished': DateTime.now(),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future followUser({required String uid, required String toFollow}) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(uid).get();

      List following = snapshot['following'];

      if (following.contains(toFollow)) {
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([toFollow])
        });

        await _firestore.collection('users').doc(toFollow).update({
          'followers': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([toFollow])
        });

        await _firestore.collection('users').doc(toFollow).update({
          'followers': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {}
  }
}
