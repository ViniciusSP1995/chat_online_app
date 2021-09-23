import 'package:chat/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
 
void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 
  runApp(MyApp());

/*     await Firebase.initializeApp();

     FirebaseFirestore.instance.collection('mensagens').snapshots().listen((dado){
       dado.docs.forEach((d){
         print(d.data);
       });
     });


/*     FirebaseFirestore.instance.collection("mensagens").doc("msg2").collection("arquivos").doc().set({
      "arqname" : 'foto.png'
      }); */ */
}
 
class MyApp extends StatelessWidget {
 
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
 
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.blue,
        ),
      ),
      home: ChatScreen(),
    );
  }
}