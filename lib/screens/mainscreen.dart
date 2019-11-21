import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:provider/provider.dart';
import "package:intl/intl.dart";
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:instagram_clone/screens/myProfileScreen.dart';
import 'package:instagram_clone/screens/userProfile.dart';
import 'package:instagram_clone/screens/onePost.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram_clone/screens/comments.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int screen = 0;

  @override
  Widget build(BuildContext context) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Instagram"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: screen, // this will be set when a new tab is tapped
        onTap: (int i) {
          setState(() {
            this.screen = i;
          });

          if (i == 4) {
            // MyProfile();
            print("Going to my profile");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyProfile()));
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
      body: ListView.builder(
        itemCount: bloc.timeline.length,
        itemBuilder: (_, i) {
          Post p = bloc.timeline[i];

          if (p.profile_image_url == null) {
            p.profile_image_url =
                "https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg";
          }

          return PostView(p);
        },
      ),
    );
  }
}

class PostView extends StatefulWidget {
  final Post post;
  const PostView(this.post);
  // const PostView(this.post, this.user);

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  String likes_count(int likes) {
    String likes_msg = "";
    var likes_ct = new NumberFormat.compact();

    if (likes == 1) {
      likes_msg = "1 like";
    } else {
      likes_msg = "${(likes_ct.format(likes))} likes";
    }

    return likes_msg;
  }

  Widget caption() {
    if (widget.post.caption == "") {
      return Row();
    }

    return RichText(
      text: TextSpan(
          text: "",
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
                text: widget.post.username + "  ",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: widget.post.caption)
          ]),
    );

    // return Row(
    //   children: <Widget>[
    //     Text(
    //       widget.post.username + "  ",
    //       style: TextStyle(fontWeight: FontWeight.w700),
    //     ),
    //     Column(
    //       children: <Widget>[
    //         Text(widget.post.caption),
    //       ],
    //     ),
    //   ],
    // );
  }

  String datePosted(DateTime _date) {
    DateFormat d = new DateFormat.yMMMd(
        "en_US"); //Obect of class to format date as (Jan 28, 2019)
    String date = d.format(_date);

    return date;
  }

  Widget commentsCt() {
    String msg = "";

    if (widget.post.comments_count == 1) {
      msg += "View 1 comment";
    } else if (widget.post.comments_count > 1) {
      msg += "View all ${widget.post.comments_count} comments";
    }

    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Comments(widget.post)));
      },
      child: Text(msg, style: TextStyle(color: Colors.black.withOpacity(0.5))),
    );
  }

  Widget addComment() {
    return Stack(alignment: const Alignment(1.0, 1.0), children: <Widget>[
      TextField(
          controller: commentTxt,
          decoration: InputDecoration(hintText: "Add a comment...")),
      RaisedButton(
        child: Text("Post"),
        onPressed: () => {},
      )
    ]);
  }

  TextEditingController commentTxt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    // print(u.email);
    return Wrap(children: <Widget>[
      Row(
        children: <Widget>[
          Container(
              width: 40.0,
              height: 40.0,
              margin: EdgeInsets.all(9.0),
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.post.profile_image_url)))),
          //       Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child:

          //         CircleAvatar(
          //           radius: 20,
          //           backgroundImage: CachedNetworkImage(
          //     imageUrl: widget.post.profile_image_url,
          //     placeholder: (context, url) => CircularProgressIndicator(),
          //     errorWidget: (context, url, error) => Icon(Icons.error),
          //  ),
          //           // backgroundColor: Colors.blue,
          //         ),
          //       ),
          Column(
            children: <Widget>[
              Container(
                  width: 150,
                  child: InkWell(
                    onTap: () {
                      if (widget.post.username == bloc.myAccount.email) {
                        // print("smae shit nigga");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyProfile()));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserProfile(widget.post.user_id)));
                      }
                    },
                    child: Text(
                      widget.post.username,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  )),
              Container(
                  width: 150,
                  child: Text(
                    "Edinburg, Texas",
                    textAlign: TextAlign.start,
                  )),
            ],
          ),
          Container(
            width: 200,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.more_horiz,
                color: Colors.black,
                size: 24.0,
              ),
            ),
          ),
        ],
      ),
      CachedNetworkImage(
        imageUrl: widget.post.image_url,
        placeholder: (context, url) => Row(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.black,
                      // size: 28.0,
                    ),
                  ),
                ),
              ),
              Container(
                width: 110,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.bookmark_border,
                      color: Colors.black,
                      size: 25.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
              child: Text(likes_count(widget.post.likes_count))),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
            child: caption(),
            // Row(
            //   children: <Widget>[
            //     Text(
            //       widget.post.username + "  ",
            //       style: TextStyle(
            //         fontWeight: FontWeight.w700,
            //       ),
            //     ),
            //     caption(widget.post.caption),
            //   ],
            // ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: commentsCt(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
            child: FutureBuilder(
                future: Future.delayed(Duration(milliseconds: 2000)),
                builder: (c, s) => s.connectionState == ConnectionState.done
                    ? addComment()
                    : Text("")),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 20.0),
            child: Text(
              datePosted(widget.post.created_at),
              style: TextStyle(color: Colors.black.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    ]);
  }
}
