import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/services/storage_services.dart';
import 'package:instagram_clone/model/user.dart' as model;

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageServices _storageServices = StorageServices();

  Future<model.User> getUserDetails() async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();

    return model.User.snapToUser(snapshot);
  }

  Future<String> createUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String result = "Some error occurred";

    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty &&
          file.isNotEmpty) {
        UserCredential credentials = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String imageUrl = await _storageServices.uploadImage(
            file: file, folder: 'profile_pictures');

        model.User user = model.User(
          email: email,
          username: username,
          bio: bio,
          uid: credentials.user!.uid,
          photo: imageUrl,
          followers: [],
          following: [],
        );

        await _firestore
            .collection('users')
            .doc(credentials.user!.uid)
            .set(user.toJson());

        result = "Success";
      }
    } catch (err) {
      result = err.toString();
    }

    return result;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String result = "Error";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        result = "success";
      } else {
        result = "Enter credentials";
      }
    } catch (err) {
      result = err.toString();
    }

    return result;
  }

  Future signOut() async {
    await _auth.signOut();
  }
}
