import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nri_campus_dairy/models/user.dart' as model;
import 'package:nri_campus_dairy/providers/user_provider.dart';
import 'package:nri_campus_dairy/resources/firestore_methods.dart';
import 'package:nri_campus_dairy/screens/comments_screen.dart';
import 'package:nri_campus_dairy/utils/colors.dart';
import 'package:nri_campus_dairy/utils/global_variable.dart';
import 'package:nri_campus_dairy/utils/utils.dart';
import 'package:nri_campus_dairy/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Material(
        child: Container(
          // boundary needed for web
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: width > webScreenSize
                  ? secondaryColor
                  : mobileBackgroundColor,
            ),
            color: mobileBackgroundColor,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          margin: const EdgeInsets.only(
            bottom: 5,
          ),
          child: Column(
            children: [
              // HEADER SECTION OF THE POST
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ).copyWith(right: 0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.snap['profImage'].toString(),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.snap['username'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    widget.snap['uid'].toString() == user.uid
                        ? IconButton(
                            onPressed: () {
                              showDialog(
                                useRootNavigator: false,
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: ListView(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shrinkWrap: true,
                                        children: [
                                          'Delete',
                                        ]
                                            .map(
                                              (e) => InkWell(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                    child: Text(e),
                                                  ),
                                                  onTap: () {
                                                    deletePost(
                                                      widget.snap['postId']
                                                          .toString(),
                                                    );
                                                    // remove the dialog box
                                                    Navigator.of(context).pop();
                                                  }),
                                            )
                                            .toList()),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.more_vert),
                          )
                        : Container(),
                  ],
                ),
              ),
              // IMAGE SECTION OF THE POST
              GestureDetector(
                onDoubleTap: () {
                  FireStoreMethods().likePost(
                    widget.snap['postId'].toString(),
                    user.uid,
                    widget.snap['likes'],
                  );
                  setState(() {
                    isLikeAnimating = true;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.50,
                          width: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.snap['postUrl'].toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLikeAnimating ? 1 : 0,
                      child: LikeAnimation(
                        isAnimating: isLikeAnimating,
                        duration: const Duration(
                          milliseconds: 400,
                        ),
                        onEnd: () {
                          setState(() {
                            isLikeAnimating = false;
                          });
                        },
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // LIKE, COMMENT SECTION OF THE POST
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LikeAnimation(
                          isAnimating: widget.snap['likes'].contains(user.uid),
                          smallLike: true,
                          child: IconButton(
                            icon: widget.snap['likes'].contains(user.uid)
                                ? const Icon(
                                    CupertinoIcons.heart_fill,
                                    color: Colors.red,
                                  )
                                : const Icon(
                                    CupertinoIcons.heart,
                                  ),
                            onPressed: () => FireStoreMethods().likePost(
                              widget.snap['postId'].toString(),
                              user.uid,
                              widget.snap['likes'],
                            ),
                          ),
                        ),
                        Text(
                          '${widget.snap['likes'].length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.chat_bubble,
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CommentsScreen(
                                  postId: widget.snap['postId'].toString(),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '$commentLen',
                            style: const TextStyle(
                              fontSize: 14,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // TODO: Add share button
                    // IconButton(
                    //     icon: const Icon(
                    //       Icons.send,
                    //     ),
                    //     onPressed: () {}),
                    // Expanded(
                    //     child: Align(
                    //   alignment: Alignment.bottomRight,
                    //   child: IconButton(
                    //       icon: const Icon(Icons.bookmark_border), onPressed: () {}),
                    // ))
                    Text(
                      DateFormat.yMMMMd()
                          .format(widget.snap['datePublished'].toDate()),
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              //DESCRIPTION AND NUMBER OF COMMENTS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // DefaultTextStyle(
                    //     style: Theme.of(context)
                    //         .textTheme
                    //         .titleSmall!
                    //         .copyWith(fontWeight: FontWeight.w800),
                    //     child: Text(
                    //       '${widget.snap['likes'].length} likes',
                    //       style: Theme.of(context).textTheme.bodyMedium,
                    //     )),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: primaryColor),
                          children: [
                            TextSpan(
                              text: widget.snap['username'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' ${widget.snap['description']}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    // InkWell(
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(vertical: 4),
                    //     child: Text(
                    //       'View all $commentLen comments',
                    //       style: const TextStyle(
                    //         fontSize: 14,
                    //         color: secondaryColor,
                    //       ),
                    //     ),
                    //   ),
                    //   onTap: () => Navigator.of(context).push(
                    //     MaterialPageRoute(
                    //       builder: (context) => CommentsScreen(
                    //         postId: widget.snap['postId'].toString(),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(vertical: 4),
                    //   child: Text(
                    //     DateFormat.yMMMd()
                    //         .format(widget.snap['datePublished'].toDate()),
                    //     style: const TextStyle(
                    //         color: secondaryColor, fontSize: 14),
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
