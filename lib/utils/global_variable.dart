import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nri_campus_dairy/screens/add_post_screen.dart';
import 'package:nri_campus_dairy/screens/feed_screen.dart';
import 'package:nri_campus_dairy/screens/profile_screen.dart';
import 'package:nri_campus_dairy/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Center(child: Text('notifications')),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
