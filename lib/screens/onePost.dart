import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:instagram_clone/screens/loadingscreen.dart';
import 'package:instagram_clone/screens/myProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:instagram_clone/models/user.dart';
import "package:intl/intl.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/screens/comments.dart';
import 'package:instagram_clone/models/comment.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:io';

class OnePost extends StatefulWidget {
  final Post post;

  const OnePost(this.post);

  @override
  _OnePostState createState() => _OnePostState();
}

class _OnePostState extends State<OnePost> {
  int screen = 0;
  Comment c = Comment();

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

  Widget caption(String caption) {
    if (caption == "") {
      return Row();
    }

    return Text(
      caption,
      style: TextStyle(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  String datePosted(DateTime _date) {
    DateFormat d = new DateFormat.yMMMd(
        "en_US"); //Obect of class to format date as (Jan 28, 2019)
    String date = d.format(_date);

    return date;
  }

  TextEditingController commentTxt = TextEditingController();

  Widget addComment() {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);

    return Stack(alignment: const Alignment(1.0, 1.0), children: <Widget>[
      TextField(
          controller: commentTxt,
          decoration: InputDecoration(hintText: "Add a comment...")),
      RaisedButton(
        child: Text("Post"),
        onPressed: () => {
          c
              .postComment(widget.post.id, bloc.token, commentTxt.text)
              .then((onValue) => {
                    if (onValue)
                      {
                        setState(() {
                          //bloc.post.comments_count++;
                          widget.post.comments_count++;
                          commentTxt.clear();
                        })
                      }
                  })
        },
      )
    ]);
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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Comments(widget.post)));
      },
      child: Text(msg, style: TextStyle(color: Colors.black.withOpacity(0.5))),
    );
  }

  // Future<bool>  getBool() async{
  //   await new Future.delayed(const Duration(seconds: 2));
  //   return true;
  // }

  Future<void> _deletePost(Post post, InstagramBloc bloc) async {
    final response = await http.delete(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/${post.id}",
        headers: {HttpHeaders.authorizationHeader: "Bearer ${bloc.token}"});

    log("deleting post...");

    if (response.statusCode == 202) {
      // log(response.body);
      log("successfully deleted");

      Navigator.pop(context, true);

      // bloc.fetchAccount().then((onValue) {
      //   if (onValue) {
      //     Navigator.push(
      //         context, MaterialPageRoute(builder: (context) => MyProfile()));
      //   }
      // });
    } else {
      // log(response.body);
      log("There was a problem deleting the post :(");
    }
  }

  _displayDialog(BuildContext context) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Post'),
            content: Text("Are you sure you want to delete this post?"),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                    child: Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deletePost(widget.post, bloc);
                      // var response =
                      //     await widget.post.deletePost(widget.post, bloc);

                      // if (response) {
                      //   Navigator.of(context).pop();
                      //   Navigator.push(context,
                      //       MaterialPageRoute(builder: (context) => MyProfile()));
                      // } else {
                      //   LoadingScreen();
                      // }
                      // _editItem(_textFieldController.text, data);
                      // _textFieldController.clear();
                    },
                  ),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    User myAccount = bloc.myAccount;

    if (widget.post.user_id == myAccount.id) {
      screen = 4;
    } else {
      screen = 0;
    }

    if (widget.post.profile_image_url == null) {
      widget.post.profile_image_url =
          "https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg";
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.post.username),
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
        body: SingleChildScrollView(
          child: Wrap(children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage(widget.post.profile_image_url),
                    //backgroundColor: Colors.blue,
                  ),
                ),
                Column(
                  children: <Widget>[
                    Container(
                        width: 150,
                        child: Text(
                          widget.post.username,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        )),
                    Container(
                        width: 150,
                        child: Text(
                          "Edinburg, Texas",
                          textAlign: TextAlign.start,
                        )),
                  ],
                ),
                Flexible(
                  child: Container(
                    width: 200,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: Icon(Icons.more_horiz),
                          color: Colors.black,

                          onPressed: () {
                            if (widget.post.user_id == myAccount.id) {
                              _displayDialog(context);
                            }
                          },
                          // size: 24.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CachedNetworkImage(
              imageUrl: widget.post.image_url,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            //Image.network(widget.post.image_url),
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
                          child: IconButton(
                            icon: widget.post.liked
                                ? Icon(Icons.favorite, color: Colors.red)
                                : Icon(Icons.favorite_border,
                                    color: Colors.black),
                            onPressed: () {
                              setState(() {
                                widget.post.liked = !widget.post.liked;
                                widget.post.likes_count++;

                                if (widget.post.liked == false) {
                                  widget.post.likes_count =
                                      widget.post.likes_count - 2;
                                }
                              });
                            },
                            // size: 28.0,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
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
                    ),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
                    child: Text(likes_count(widget.post.likes_count))),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
                  child: caption(widget.post.caption),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: commentsCt(),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 15.0),
                    child: addComment()),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    datePosted(widget.post.created_at),
                    style: TextStyle(color: Colors.black.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ]),
        ));
  }
}
