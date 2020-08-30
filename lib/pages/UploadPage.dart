import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jgram/models/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jgram/widgets/ProgressWidget.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;
import 'package:firebase_storage/firebase_storage.dart';
import './HomePage.dart';

class UploadPage extends StatefulWidget {
  final User gCurrentUser;

  UploadPage({this.gCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage> {
  bool uploading = false;
  String postId = Uuid().v4();

  File file;
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  bool disableLocationField = false;

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mplacemark = placeMark[0];
    String completeAddressInfo =
        "${mplacemark.subThoroughfare} ${mplacemark.thoroughfare} , ${mplacemark.subLocality} ${mplacemark.locality} , ${mplacemark.subAdministrativeArea} ${mplacemark.administrativeArea} , ${mplacemark.postalCode} ${mplacemark.country}";
    //for getting complete Address
    String reqAddress = "${mplacemark.locality} , ${mplacemark.country}";
    locationTextEditingController.text = reqAddress;
  }

  captureFromCamera() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
    setState(() {
      this.file = imageFile;
    });
  }

  captureFromGallery() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 680, maxWidth: 970);
    setState(() {
      this.file = imageFile;
    });
  }

  takeImage(ctx) {
    return showDialog(
        context: ctx,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(5),
            backgroundColor: Colors.white,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text(
              'New Post',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            children: [
              SizedBox(
                height: 10,
              ),
              SimpleDialogOption(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.photo_camera),
                      onPressed: captureFromCamera,
                    ),
                    Text(
                      'Capture From Mobile',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                onPressed: captureFromCamera,
              ),
              SizedBox(
                height: 5,
              ),
              SimpleDialogOption(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.photo),
                      onPressed: captureFromGallery,
                    ),
                    Text(
                      'Choose from Gallery',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                onPressed: captureFromGallery,
              )
            ],
          );
        });
  }

  displayUploadScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            color: Colors.grey,
            size: 200,
          ),
          SizedBox(
            height: 10,
          ),
          RaisedButton(
            padding: EdgeInsets.all(10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.green,
            onPressed: () => takeImage(context),
            child: Text('Upload',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          )
        ],
      ),
    );
  }

  clearPostInfo() {
    descriptionTextEditingController.clear();
    locationTextEditingController.clear();
    setState(() {
      file = null;
    });
  }

  displayUploadForm() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          'New Post',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: clearPostInfo),
        actions: [
          FlatButton(
            onPressed: controlUploadAndSave,
            color: Colors.black,
            child: Text(
              'Share',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          uploading?linearProgress():Text(''),
          Container(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                child: Image(
                  image: FileImage(file),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(widget.gCurrentUser.url),
              ),
              title: Container(
                width: 250,
                child: TextField(
                  controller: descriptionTextEditingController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: 'Say something about post',
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none),
                ),
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(
                Icons.person_pin_circle,
                size: 40,
                color: Colors.white,
              ),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationTextEditingController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Write the location here',
                    enabled: disableLocationField == true ? false : true,
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Container(
                height: 50,
                width: 250,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  onPressed: () {
                    getUserLocation();
                    disableLocationField = true;
                  },
                  color: Colors.green,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      Text(
                        'Get your Location',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });
    await compressingPhoto();
    String downloadUrl = await uploadPhoto(file);
    savePostIntoFireStore(
        url: downloadUrl,
        description: descriptionTextEditingController.text,
        location: locationTextEditingController.text);
    descriptionTextEditingController.clear();
    locationTextEditingController.clear();
    setState(() {
      file=null;
      uploading=false;
      postId=Uuid().v4();
    });
  }

// compressing my file to avoid crazy peoples like me dyan se
  compressingPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File("$path/img_$postId.jpg")
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 90));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask storageUploadTask =
        storageReference.child("posts_$postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  savePostIntoFireStore({String url, String location, String description}) {
    postReference
        .document(widget.gCurrentUser.id)
        .collection("usersPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "OwnerId": widget.gCurrentUser.id,
      "timeStamp": timeStamp,
      "likes": {},
      "username": widget.gCurrentUser.username,
      "description": description,
      "location": location,
      "url": url,
    });
  }
  bool get wantKeepAlive=>true;
  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen() : displayUploadForm();
  }
}
