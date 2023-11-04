import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nri_campus_dairy/models/user.dart' as model;
import 'package:nri_campus_dairy/providers/user_provider.dart';
import 'package:nri_campus_dairy/utils/colors.dart';
import 'package:nri_campus_dairy/utils/global_variable.dart';
import 'package:nri_campus_dairy/widgets/post_card.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              automaticallyImplyLeading: false,
              title: const Text(
                'Home',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // SvgPicture.asset(
              //   'assets/ic_instagram.svg',
              //   color: primaryColor,
              //   height: 32,
              // ),
              // actions: [
              //   IconButton(
              //     icon: const Icon(
              //       Icons.messenger_outline,
              //       color: primaryColor,
              //     ),
              //     onPressed: () {},
              //   ),
              // ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .orderBy("datePublished", descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.none) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return snapshot.data!.docs.isEmpty
              ? Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'Add friends and post to see 😋',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) => Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: width > webScreenSize ? width * 0.3 : 0,
                      vertical: width > webScreenSize ? 15 : 0,
                    ),
                    child: PostCard(
                      snap: snapshot.data!.docs[index].data(),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
