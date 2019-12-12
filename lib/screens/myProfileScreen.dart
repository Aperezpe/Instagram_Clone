import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:instagram_clone/screens/onePost.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:developer';
import 'newPost.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  int screen = 4;
  // TextEditingController usernameCtrl = TextEditingController();
  // TextEditingController passwordCtrl = TextEditingController();

  Future openImagePicker() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // String base64Img = base64Encode(image.readAsBytesSync());

    if (image != null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NewPost(image)));
    }
  }

  @override
  Widget build(BuildContext context) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    User myAccount = bloc.myAccount;

    if (myAccount.profile_image_url == null) {
      myAccount.profile_image_url =
          "https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg";
    }

    Widget postsMsg(int count) {
      String msg = "";

      if (count > 1) {
        msg += "Posts";
      } else {
        msg += "Post";
      }

      return Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Column(
          children: <Widget>[Text(count.toString()), Text(msg)],
        ),
      );
    }

    Widget myBio() {
      String bio = "";
      if (myAccount.bio != null) {
        bio = myAccount.bio;
      }
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
            child: Align(alignment: Alignment.centerLeft, child: Text(bio)),
          ),
        ],
      );
    }

    Widget myProfileHeader() {
      return Row(
        children: <Widget>[
          Container(
              width: 70.0,
              height: 70.0,
              margin: EdgeInsets.all(20.0),
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: new NetworkImage(myAccount.profile_image_url)))),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: CircleAvatar(
          //     radius: 20,
          //     // backgroundImage: NetworkImage("https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg"),
          //     backgroundColor: Colors.blue,
          //   ),
          // ),
          postsMsg(bloc.my_posts.length),
        ],
      );
    }

    Card getStructuredGridCell(Post post, int index) {
      return Card(
          elevation: 1.5,
          child: InkWell(
            onTap: () async {
              final res = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OnePost(post)));

              if (res != null) {
                //delete post from real list
                setState(() {
                  bloc.my_posts.removeAt(index);
                });
              }

              // log((result).toString());
            },
            child: Column(children: <Widget>[
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: post.image_url,
                  placeholder: (context, url) => Row(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ]),
          ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(bloc.myAccount.email),
          leading: Container(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: screen, // this will be set when a new tab is tapped
          onTap: (int i) {
            setState(() {
              this.screen = i;
            });
            if (i == 0) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MainScreen()));
            } else if (i == 2) {
              // MyProfile();
              openImagePicker();
              // print("Going to new post");
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => NewPost()));
            }
          },

          items: [
            BottomNavigationBarItem(
              icon: new Icon(MdiIcons.homeOutline, color: Colors.black87),
              activeIcon: new Icon(MdiIcons.home, color: Colors.black87),
              title: new Text(""),
            ),
            BottomNavigationBarItem(
                icon: new Icon(Icons.search),
                activeIcon: new Icon(Icons.search, color: Colors.black87),
                title: new Text("")),
            BottomNavigationBarItem(
                icon: new Icon(
                  MdiIcons.plusBoxOutline,
                  color: Colors.black87,
                ),
                activeIcon: new Icon(MdiIcons.plusBox, color: Colors.black87),
                title: new Text("")),
            BottomNavigationBarItem(
                icon: new Icon(
                  MdiIcons.heartOutline,
                  color: Colors.black87,
                ),
                activeIcon: new Icon(MdiIcons.heart, color: Colors.black87),
                title: new Text("")),
            BottomNavigationBarItem(
                icon: new Icon(
                  MdiIcons.accountOutline,
                  color: Colors.black87,
                ),
                activeIcon: new Icon(MdiIcons.account, color: Colors.black87),
                title: new Text("")),
          ],
        ),
        body: Column(
          children: <Widget>[
            myProfileHeader(),
            myBio(),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(bloc.my_posts.length, (index) {
                  return getStructuredGridCell(bloc.my_posts[index], index);
                }),
              ),
            )
          ],
        ));
  }
}
