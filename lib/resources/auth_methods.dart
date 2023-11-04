import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nri_campus_dairy/models/user.dart' as model;
import 'package:nri_campus_dairy/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Signing Up User

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Uh-oh! 😕 An error has popped up.";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        // registering user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: [],
          following: [],
        );

        // adding user in our database
        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(user.toJson());

        res = "success";
      } else {
        res = "Complete all fields for signup. Thanks!";
      }
    } on FirebaseAuthException catch (err) {
      return err.message.toString();
    }
    print(res.toString());
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "🙅‍♂️ Oops! Please double-check your inputs and try again.";
      }
    } on FirebaseAuthException catch (err) {
      switch (err.code.toString()) {
        case 'invalid-email':
          res = 'Oops! The email you entered doesn\'t seem to be valid.';
          break;
        case 'unknown':
          res = ' Uh-oh! It looks like something\'s not quite right.';
          break;
        case 'wrong-password':
          res = 'The password is invalid';
          break;
        default:
      }
      print(err.toString());
      // return err.message!;
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User check for signup -----------------------------------------------------
  Future<String> signupCheck({required int passCode}) async {
    String res = 'Invalid Code :(';

    QuerySnapshot snap = await _firestore.collection('passCode').get();

    for (DocumentSnapshot documentSnapshot in snap.docs) {
      int key = documentSnapshot.get('code');
      if (passCode == key) {
        res = 'success';
        break;
      }
    }
    return res;
  }
}
