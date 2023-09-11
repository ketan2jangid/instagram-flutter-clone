import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/services/authentication.dart';
import 'package:instagram_clone/services/firestore_services.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/profile_action_button.dart';
import 'package:instagram_clone/widgets/snack_bar.dart';

import '../widgets/stats_block.dart';

class ProfileScreen extends StatefulWidget {
  String uid;

  ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userInfo;
  int noOfPosts = 0;
  bool isFollowing = false;
  bool fetchingData = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      fetchingData = true;
    });

    try {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postsData = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      setState(() {
        userInfo = userData.data();
        noOfPosts = postsData.docs.length;
        isFollowing = userData['followers'].contains(widget.uid);
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    setState(() {
      fetchingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return fetchingData
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(userInfo['username']),
      ),
      body: ListView(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        userInfo['photo'],
                      ),
                      radius: 45,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              StatsBlock(num: noOfPosts, label: 'posts'),
                              StatsBlock(
                                  num: userInfo['followers'].length,
                                  label: 'followers'),
                              StatsBlock(
                                  num: userInfo['following'].length,
                                  label: 'following'),
                            ],
                          ),
                          FirebaseAuth.instance.currentUser!.uid ==
                              widget.uid
                              ? ProfileActionButton(
                            buttonLabel: 'Logout',
                            buttonColor: mobileBackgroundColor,
                            buttonBorder: secondaryColor,
                            action: () {
                              Authentication().signOut();
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const LoginScreen()));
                            },
                          )
                              : isFollowing
                              ? ProfileActionButton(
                            buttonLabel: 'Unfollow',
                            buttonColor: mobileBackgroundColor,
                            buttonBorder: secondaryColor,
                            action: () {
                              FirestoreServices().followUser(
                                  uid: FirebaseAuth.instance
                                      .currentUser!.uid,
                                  toFollow: userInfo['uid']);

                              setState(() {
                                isFollowing = false;
                              });
                            },
                          )
                              : ProfileActionButton(
                            buttonLabel: 'Follow',
                            buttonColor: blueColor,
                            buttonBorder: secondaryColor,
                            action: () {
                              FirestoreServices().followUser(
                                  uid: FirebaseAuth.instance
                                      .currentUser!.uid,
                                  toFollow: userInfo['uid']);

                              setState(() {
                                isFollowing = true;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  child: Text(
                    userInfo['username'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  child: Text(userInfo['bio']),
                ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('posts')
                .where('uid', isEqualTo: widget.uid)
                .get(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                snapshot) {
              if (snapshot.connectionState == AsyncSnapshot.waiting()) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 1.5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return Container(
                      child: Image(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            snapshot.data!.docs[index]['postUrl']),
                      ));
                },
              );
            },
          )
        ],
      ),
    );
  }
}
