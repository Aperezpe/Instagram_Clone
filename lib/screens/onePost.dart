import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:instagram_clone/models/user.dart';
import "package:intl/intl.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/screens/comments.dart';

class OnePost extends StatefulWidget {
  final Post post;

  const OnePost(this.post);

  @override
  _OnePostState createState() => _OnePostState();
}

class _OnePostState extends State<OnePost> {
  int screen = 0;

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
                // Container(
                //     width: 40.0,
                //     height: 40.0,
                //     margin: EdgeInsets.all(9.0),
                //     decoration: new BoxDecoration(
                //         shape: BoxShape.circle,
                //         image: new DecorationImage(
                //             fit: BoxFit.cover,
                //             image: new NetworkImage(myAccount.profile_image_url)))),
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
                  child: caption(widget.post.caption),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: commentsCt(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 15.0),
                  child: FutureBuilder(
                      future: Future.delayed(Duration(milliseconds: 2000)),
                      builder: (c, s) =>
                          s.connectionState == ConnectionState.done
                              ? addComment()
                              : Text("")),
                ),
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
