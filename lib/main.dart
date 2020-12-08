import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics analytics;

void main() {
  analytics = FirebaseAnalytics();
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
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  analyticsEvents() {
    analytics.logEvent(name: 'button_press');
    print('event logged');
  }

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _selectedFile;
  bool _inProcess = false;

  Future<void> uploadFile(BuildContext context) async {
    String filename = basename(_selectedFile.path);
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('images/$filename}');
    StorageUploadTask uploadTask = storageReference.putFile(_selectedFile);
    // ignore: unused_local_variable
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      print('Image Uploaded');
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Suspect image uploaded')));
    });
  }

  Widget getImageWidget() {
    if (_selectedFile != null) {
      return Image.file(
        _selectedFile,
        width: 450,
        height: 650,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "assets/images.jpg",
        width: 420,
        height: 650,
        fit: BoxFit.cover,
      );
    }
  }

  getImage(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          //aspectRatio: CropAspectRatio(
          //ratioX: 1, ratioY: 1),
          //compressQuality: 100,
          // maxWidth: 700,
          //maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blue,
            toolbarTitle: "Crop it",
            statusBarColor: Colors.blueGrey,
            backgroundColor: Colors.white,
          ));

      this.setState(() {
        _selectedFile = cropped;
        _inProcess = false;
      });
    } else {
      this.setState(() {
        _inProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          getImageWidget(),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                      height: 75,
                      minWidth: 185,
                      color: Colors.blue,
                      child: Text(
                        "Add Image",
                        style: TextStyle(color: Colors.white, fontSize: 23),
                      ),
                      onPressed: () {
                        getImage(ImageSource.gallery);
                      }),
                  MaterialButton(
                      height: 75,
                      minWidth: 185,
                      color: Colors.blue,
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white, fontSize: 23),
                      ),
                      onPressed: () {
                        uploadFile(context);
                      }),
                ],
              )
            ],
          ),
          (_inProcess)
              ? Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center()
        ],
      ),
    );
  }
}
