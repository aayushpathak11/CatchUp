
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling.dart';
import 'package:firebase_database/firebase_database.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDarWXEvk0OUvAR-1PJkREc0oaowFpyI8M",
          appId: "1:341299393556:web:a7361edb8da40ffb55a301",
          messagingSenderId: "341299393556",
          projectId: "mywebrtc-6c41e")
  );
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  String? vacant;
  String? screen_flag;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
    });
    signaling.openUserMedia(_localRenderer, _remoteRenderer);
    screen_flag="true";
    super.initState();
  }

  // @override
  // void dispose() {
  //   _localRenderer.dispose();
  //   _remoteRenderer.dispose();
  //   screen_flag="false";
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        title: Text("Welcome to Flutter Explained - WebRTC"),

      ),
      body: Column(

        children: [

          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ElevatedButton(
              //   onPressed: () {
              //
              //   },
              //   child: Text("Open camera & microphone"),
              // ),
              // SizedBox(
              //   width: 8,
              // ),
              ElevatedButton(
                onPressed: () async {
                  vacant="";
                  //user media ( camera and media)

                  //fetching the vacant room
                  // FirebaseFirestore.instance.collection("vacantrooms").add({"available":roomId});
                  CollectionReference _collectionRef = FirebaseFirestore.instance.collection('vacantrooms');

                  QuerySnapshot querySnapshot = await _collectionRef.get();

                  List allData = querySnapshot.docs.map((doc) => doc.data()).toList();
                  if(allData.length==0) {
                    vacant == "";
                  }
                  else {
                    vacant = allData[0]['available'].toString();
                  }
                  print(vacant);


                  if(vacant==""){
                    print(vacant);

                    //create room
                    roomId = await signaling.createRoom(_remoteRenderer);

                    //empty vacant room
                    // var collection = FirebaseFirestore.instance.collection('vacantrooms');
                    // var snapshots = await collection.get();
                    // for (var doc in snapshots.docs) {
                    //   await doc.reference.delete();
                    // }
                    // print(vacant);

                    //fill vacant room
                    FirebaseFirestore.instance.collection("vacantrooms").add({"available":roomId});
                    // CollectionReference _collectionRef = FirebaseFirestore.instance.collection('vacantrooms');
                    print(vacant);
                    // roomId=null;


                  }
                  else{
                    print(vacant);
                    //joining a vacant room
                    signaling.joinRoom(
                      vacant!,
                      _remoteRenderer,
                    );

                    // empty vacant
                    var collection = FirebaseFirestore.instance.collection('vacantrooms');
                    var snapshots = await collection.get();
                    for (var doc in snapshots.docs) {
                      await doc.reference.delete();
                    }
                    print(vacant);

                  }

                  setState(() {});
                },
                child: Text("Connect"),
              ),
              // SizedBox(
              //   width: 8,
              // ),
              // ElevatedButton(
              //   onPressed: () {
              //     // Add roomId
              //     signaling.joinRoom(
              //       textEditingController.text,
              //       _remoteRenderer,
              //     );
              //   },
              //   child: Text("Join room"),
              // ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {

                  signaling.hangUp(_localRenderer , _remoteRenderer);



                  setState(() {
                  });
                },
                child: Text("Hangup"),
              )
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(

                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Text("Join the following Room: "),
          //       Flexible(
          //         child: TextFormField(
          //           controller: textEditingController,
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}
