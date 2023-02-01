import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning_seminar_2023/constants/colors.dart';
import 'package:e_learning_seminar_2023/constants/images.dart';
import 'package:e_learning_seminar_2023/models/userModel.dart';
import 'package:e_learning_seminar_2023/view/dashboard/comment.dart';
import 'package:e_learning_seminar_2023/view/dashboard/postVideo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/src/widgets/text.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../models/postModel.dart';
import 'createPost.dart';

class atDashboardScreen extends StatefulWidget {
  final String uid;
  atDashboardScreen(required, {Key? key, required this.uid}) : super(key: key);

  @override
  _atDashboardScreen createState() => _atDashboardScreen(uid);
}

class _atDashboardScreen extends State<atDashboardScreen>
    with SingleTickerProviderStateMixin {
  String uid = '';
  _atDashboardScreen(uid);

  bool liked = false;
  bool silent = false;
  bool isVideo = false;

  File? videoFile;

  File? imageFile;

  late userModel user = userModel(
      avatar: '',
      background: '',
      email: '',
      favoriteList: [],
      fullName: '',
      id: '',
      phoneNumber: '',
      saveList: [],
      state: '',
      userName: '',
      follow: [],
      role: '',
      gender: '',
      dob: '');
  List y = [];
  Future getUserDetail() async {
    FirebaseFirestore.instance
        .collection("users")
        .where("userId", isEqualTo: uid)
        .snapshots()
        .listen((value) {
      setState(() {
        user = userModel.fromDocument(value.docs.first.data());

        y = user.follow;
      });
    });
  }

  List<postModel> postList = [];
  List<postModel> postListCheck = [];
  Future getPostList() async {
    FirebaseFirestore.instance
        .collection("posts")
        .orderBy('timeCreate', descending: true)
        .snapshots()
        .listen((value) {
      setState(() {
        postList.clear();
        postListCheck.clear();
        value.docs.forEach((element) {
          if (element.data()["state"] == "show") {
            postListCheck.add(postModel.fromDocument(element.data()));
          }
        });
        postListCheck.forEach((element) {
          if (y.contains(element.idUser)) {
            postList.add(element);
          }
        });
      });
    });
  }

  late VideoPlayerController _videoPlayerController;

  late ChewieController _chewieController =
      ChewieController(videoPlayerController: _videoPlayerController);
  bool check = false;
  bool play = false;

  Future<void> controlOnRefresh() async {
    setState(() {});
  }

  late DateTime timeCreate = DateTime.now();

  Future like(String postId, List likes, String ownerId) async {
    if (likes.contains(uid)) {
      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([uid])
      }).whenComplete(() {
        if (uid != ownerId) {
          FirebaseFirestore.instance.collection('notifies').add({
            'idSender': uid,
            'idReceiver': ownerId,
            'avatarSender': user.avatar,
            'mode': 'public',
            'idPost': postId,
            'content': 'liked your photo',
            'category': 'like',
            'nameSender': user.userName,
            'timeCreate':
                "${DateFormat('y MMMM d, hh:mm a').format(DateTime.now())}"
          }).then((value) {
            FirebaseFirestore.instance
                .collection('notifies')
                .doc(value.id)
                .update({'id': value.id});
          });
        }
      });
    }
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    final userid = user?.uid.toString();
    uid = userid!;
    getUserDetail();
    getPostList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent),
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () {
              return getPostList();
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(profileBackground),
                        fit: BoxFit.cover),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 32, right: 16, left: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          user.userName,
                          style: TextStyle(
                            fontFamily: 'Recoleta',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: black,
                          ),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Container(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            atCreatePostScreen(required,
                                                uid: uid)),
                                  );
                                },
                                child: AnimatedContainer(
                                  alignment: Alignment.topRight,
                                  duration: Duration(milliseconds: 300),
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.5,
                                      )),
                                  child: Container(
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.center,
                                      child: Icon(Iconsax.add,
                                          size: 16, color: black)),
                                ),
                              )),
                          SizedBox(width: 16),
                          Container(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //           messsageScreen(required, uid: uid)),
                                // );
                              },
                              child: Container(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.topRight,
                                  child: Icon(Iconsax.message,
                                      size: 24, color: black)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(
                        top: 88, left: 16, right: 16, bottom: 56),
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(height: 16),
                        itemCount: postListCheck.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             atProfileScreen(required,
                                        //                 ownerId:
                                        //                     postList[index]
                                        //                         .idUser)));
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                postListCheck[index]
                                                    .ownerAvatar,
                                                width: 32,
                                                height: 32,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                              child: Text(
                                            postListCheck[index].ownerUsername,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.w600,
                                                color: black),
                                          ))
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        // if (uid == postList[index].idUser) {
                                        //   if (postList[index].state ==
                                        //       'show') {
                                        //     hidePostDialog(
                                        //         context, postList[index].id);
                                        //   } else {
                                        //     showPostDialog(
                                        //         context, postList[index].id);
                                        //   }
                                        // } else {
                                        //   savePostDialog(context,
                                        //       postList[index].id, uid);
                                        // }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        alignment: Alignment.topRight,
                                        child: Icon(Iconsax.more,
                                            size: 24, color: black),
                                      ),
                                    )
                                  ],
                                ),
                                (postListCheck[index].urlImage != '')
                                    ? Container(
                                        width: 360,
                                        height: 340,
                                        padding:
                                            EdgeInsets.only(top: 8, bottom: 16),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.network(
                                            postListCheck[index].urlImage,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : postVideoWidget(context,
                                        src: postListCheck[index].urlVideo),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              liked = !liked;
                                              like(
                                                  postListCheck[index].id,
                                                  postListCheck[index].likes,
                                                  postListCheck[index].idUser);
                                            });
                                          },
                                          icon: (postListCheck[index]
                                                  .likes
                                                  .contains(uid))
                                              ? Container(
                                                  padding:
                                                      EdgeInsets.only(left: 8),
                                                  alignment: Alignment.topLeft,
                                                  child: Icon(Iconsax.like_15,
                                                      size: 24, color: pink),
                                                )
                                              : Container(
                                                  padding:
                                                      EdgeInsets.only(left: 8),
                                                  alignment: Alignment.topLeft,
                                                  child: Icon(Iconsax.like_1,
                                                      size: 24, color: black),
                                                )),
                                      Container(
                                          padding: EdgeInsets.only(left: 8),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            (postListCheck[index].likes.isEmpty)
                                                ? '0'
                                                : postListCheck[index]
                                                    .likes
                                                    .length
                                                    .toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: black,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                      IconButton(
                                        padding: EdgeInsets.only(left: 8),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: ((context) =>
                                                      atCommentScreen(
                                                        required,
                                                        uid: uid,
                                                        postId:
                                                            postListCheck[index]
                                                                .id,
                                                        ownerId:
                                                            postListCheck[index]
                                                                .idUser,
                                                      ))));
                                        },
                                        icon: Container(
                                          child: Icon(Iconsax.message_text,
                                              size: 24, color: black),
                                        ),
                                      ),
                                      Spacer(),
                                      (isVideo)
                                          ? IconButton(
                                              onPressed: () {
                                                //save post
                                              },
                                              icon: (silent == true)
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          right: 8),
                                                      child: Icon(
                                                          Iconsax.volume_slash,
                                                          size: 24,
                                                          color: gray),
                                                    )
                                                  : Container(
                                                      margin: EdgeInsets.only(
                                                          right: 8),
                                                      child: Icon(
                                                          Iconsax.volume_high,
                                                          size: 24,
                                                          color: black),
                                                    ))
                                          : Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent),
                                            )
                                    ],
                                  ),
                                ),
                                // SizedBox(height: 12),
                                Container(
                                  margin: EdgeInsets.only(left: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          width: 327 + 24,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            postListCheck[index].caption,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: black,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.w600,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 1,
                                          )),
                                      SizedBox(height: 8),
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            postListCheck[index].timeCreate,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: gray,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }))
              ],
            ),
          ),
        ));
  }
}
