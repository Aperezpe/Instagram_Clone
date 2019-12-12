import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/screens/loadingscreen.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/screens/myProfileScreen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class NewPost extends StatefulWidget {
  File image;

  NewPost(this.image);

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _captionController = TextEditingController();
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    bool _isUploading = false;


    Future<Map<String, dynamic>> _uploadImage(File image) async {
      var headers = {"Authorization": "Bearer " + bloc.token};

      setState(() {
        _isUploading = true;
        if(_isUploading){
          Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoadingScreen()));
        }
      
      });
      // Find the mime type of the selected file by looking at the header bytes of the file
      final mimeTypeData =
          lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
      // Intilize the multipart request
      final imageUploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse(
              "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts"));
      imageUploadRequest.headers.addAll(headers);

      // Attach the file in the request
      final file = await http.MultipartFile.fromPath('image', image.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
      // Explicitly pass the extension of the image with request body
      // Since image_picker has some bugs due which it mixes up
      // image extension with file name like this filenamejpge
      // Which creates some problem at the server side to manage
      // or verify the file extension
      //imageUploadRequest.fields['ext'] = mimeTypeData[1];
      imageUploadRequest.fields['caption'] = _captionController.text;
      imageUploadRequest.files.add(file);

      try {
        final streamedResponse = await imageUploadRequest.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 200) {
          return null;
        }
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } catch (e) {
        print(e);
        return null;
      }
    }

    void _startUploading() async {
      final Map<String, dynamic> response = await _uploadImage(widget.image);

      print(response);

      if (response == null || response.containsKey("error")) {
        print("some error");
      } else {
        print("upload succcessfull");
        bloc.fetchAccount().then((onValue) {
          if (onValue) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyProfile()));
          }
        });
      }
      // Check if any error occured
      // if (response == null || response.containsKey("error")) {
      //   Toast.show("Image Upload Failed!!!", context,
      //       duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      // } else {
      //   Toast.show("Image Uploaded Successfully!!!", context,
      //       duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      // }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("New Post"),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.blue,
            onPressed: () => {
              _captionController != null
                  ? _startUploading()
                  : print("This shit is null")
            },
            child: Text(
              "Share",
              style: TextStyle(fontSize: 20),
            ),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          )
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, top: 15.0, right: 15.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Image.file(
                    widget.image,
                    height: 60,
                  ),
                  Flexible(
                    child: TextField(
                        controller: _captionController,
                        decoration: InputDecoration(
                            hintText: "Write a caption...",
                            contentPadding: EdgeInsets.only(left: 8.0),
                            border: InputBorder.none)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
