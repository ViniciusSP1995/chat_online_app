import 'dart:io';

import 'package:chat/chat_message.dart';
import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
final GoogleSignIn googleSignIn = GoogleSignIn();
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User? _currentUser;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {}); /* onAuthStateChanged   */
  }

  Future<User>_getUser() async {
    if (_currentUser != null) return _currentUser!;

    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,

      );

      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = authResult.user;

      return user!;
    } catch (error) {
      return null!;
    }
  }

    void _sendMessage({String? text, File? imgFile}) async {
      final User user = await _getUser();
      final File file;


      if(user == null) {
        _scaffoldKey.currentState!.showSnackBar(
          SnackBar(
            content: Text('Não foi possível fazer o login. Tente novamente!'),
            backgroundColor: Colors.red,

          ),
         
        );
      }

      Map<String, dynamic> data = {
        'uid': user.uid,
        'senderNaeme':user.displayName,
        'senderPhotoUrl': user.photoURL,
      };
      
      if(imgFile != null) {
        UploadTask task = FirebaseStorage.instance.ref().child(
          DateTime.now().millisecondsSinceEpoch.toString()
        ).putFile(imgFile);

       TaskSnapshot taskSnapshot = await task;
       String url = await taskSnapshot.ref.getDownloadURL();
       data['imgurl'] = url;
      }

      if(text != null) data['text'] = text;

    await Firebase.initializeApp();

    FirebaseFirestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Olá'),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('messages').snapshots(),
              builder: (context, snapshot){
                switch(snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                  default:
                  List<DocumentSnapshot> documents = snapshot.data!.docs.reversed.toList();

                  return ListView.builder(
                    itemCount: documents.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return ChatMessage(documents[index].data as Map<String, dynamic>, true);
                    },
                  );
                }
              },
            ),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}