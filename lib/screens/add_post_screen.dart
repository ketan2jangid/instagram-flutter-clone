import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/model/user.dart';
import 'package:instagram_clone/provider/user_provider.dart';
import 'package:instagram_clone/services/firestore_services.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/image_selector.dart';
import 'package:instagram_clone/widgets/snack_bar.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? img;
  final TextEditingController _description = TextEditingController();
  bool uploading = false;

  resetImage() {
    setState(() {
      img = null;
    });
  }

  postImage(
    String uid,
    String username,
    String profileImage,
  ) async {
    String res = "Errrr!!!";
    setState(() {
      uploading = true;
    });
    try {
      res = await FirestoreServices().uploadPost(
          username: username,
          uid: uid,
          img: img!,
          description: _description.text,
          profileImage: profileImage);

      setState(() {
        uploading = false;
      });

      res = "Posted";
    } catch (err) {
      res = err.toString();
    }
    showSnackBar(res, context);
    resetImage();
  }

  chooseImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (builder) {
          return SimpleDialog(
            title: const Text('Select Image'),
            children: [
              SimpleDialogOption(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: const Text('Take photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List image = await imageSelector(ImageSource.camera);

                  setState(() {
                    img = image;
                  });
                },
              ),
              SimpleDialogOption(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List image = await imageSelector(ImageSource.gallery);

                  setState(() {
                    img = image;
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;

    return img == null
        ? Center(
            child: IconButton(
              onPressed: () => chooseImage(context),
              icon: const Icon(
                Icons.upload,
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: resetImage,
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Add Post'),
              actions: [
                TextButton(
                  onPressed: () =>
                      postImage(user.uid, user.username, user.photo),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: blueColor),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                uploading
                    ? const LinearProgressIndicator()
                    : const Padding(
                        padding: const EdgeInsets.only(top: 0),
                      ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photo),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextField(
                        controller: _description,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Write a caption",
                        ),
                        maxLines: 10,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: AspectRatio(
                        aspectRatio: 30 / 30,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(img!),
                              fit: BoxFit.fill,
                              alignment: FractionalOffset.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          );
  }
}
