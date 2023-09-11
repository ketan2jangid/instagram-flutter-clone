import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServices {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future uploadImage({
    required Uint8List file,
    required String folder,
    bool isPost = false,
  }) async {
    Reference ref = _storage.ref().child(folder).child(_auth.currentUser!.uid);

    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    UploadTask task = ref.putData(file);
    TaskSnapshot snap = await task;

    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }
}
