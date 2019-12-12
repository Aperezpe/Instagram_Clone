import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/commentsBloc.dart';
import 'package:instagram_clone/blocs/instagrambloc.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:instagram_clone/models/user.dart';
import "package:intl/intl.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/screens/loadingscreen.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_slidable/flutter_slidable.dart';

class Comments extends StatefulWidget {
  final Post post;

  const Comments(this.post);

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    CommentsBloc bloc = CommentsBloc(widget.post);

    return ChangeNotifierProvider(
      builder: (_) => bloc,
      child: SetupWidget(),
    );
  }
}

class SetupWidget extends StatefulWidget {
  SetupWidget();

  @override
  _SetupWidgetState createState() => _SetupWidgetState();
}

class _SetupWidgetState extends State<SetupWidget> {
  @override
  Widget build(BuildContext context) {
    CommentsBloc bloc = Provider.of<CommentsBloc>(context);

    if (bloc.isReady) {
      return CommentScreen();
    } else {
      return LoadingScreen();
    }
  }
}

class CommentScreen extends StatefulWidget {
  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    CommentsBloc bloc = Provider.of<CommentsBloc>(context);
    FocusNode _focusNode = FocusNode();
    AnimationController _controller;
    Animation _animation;
    TextEditingController _inputController = TextEditingController();

    if (bloc.userAccount.profile_image_url == null) {
      bloc.userAccount.profile_image_url =
          "https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg";
    }

    Future<void> postComment() async {
      Comment c = Comment();

      if (_inputController == '') {
        print("Nothing typed");
        return;
      }

      c
          .postComment(bloc.post.id, bloc.token, _inputController.text)
          .then((onValue) => {
                if (onValue)
                  {
                    setState(() {
                      //bloc.post.comments_count++;

                      Comment newComment = Comment();
                      // newComment.id = -1;
                      newComment.user_id = bloc.myAccount.id;
                      newComment.post_id = bloc.post.id;
                      newComment.text = _inputController.text;
                      bloc.postComments.add(newComment);

                      bloc.usersMap[newComment.user_id] = bloc.myAccount;

                      _inputController.clear();
                    })
                  }
              });

      // var response = await http.post(
      //     "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/${bloc.postComments[0].post_id}/comments?text=${_inputController.text}",
      //     headers: {HttpHeaders.authorizationHeader: "Bearer ${bloc.token}"});
      // if (response.statusCode == 200) {

      //   print("Comment Successfully Added!");

      //   // usersMap[postComments[i].user_id] =
      //   //     User.fromJson(jsonDecode(userResponse.body));
      //   //users.add(User.fromJson(jsonDecode(userResponse.body)));
      // } else {
      //   print("There was a problem posting the comment");
      // }

      // setState(() {});
    }

    @override
    void initState() {
      super.initState();

      _controller = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300));
      _animation = Tween(begin: 50.0, end: 200.0).animate(_controller)
        ..addListener(() {
          setState(() {});
        });

      _focusNode.addListener(() {
        if (_focusNode.hasFocus) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    }

    @override
    void dispose() {
      _controller.dispose();
      _focusNode.dispose();

      super.dispose();
    }

    Widget userCaption() {
      return Row(
        children: <Widget>[
          Container(
              width: 40.0,
              height: 40.0,
              margin: EdgeInsets.all(9.0),
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      image:
                          NetworkImage(bloc.userAccount.profile_image_url)))),
          Expanded(
            child: RichText(
              text: TextSpan(
                  text: '',
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: bloc.userAccount.email + "  ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: bloc.caption,
                    ),
                  ]),
            ),
          ),
        ],
      );
    }

    Widget commentBox() {
      if (bloc.myAccount.profile_image_url == null) {
        bloc.myAccount.profile_image_url =
            "https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg";
      }

      if (_animation == null) {
        return InkWell(
          // to dismiss the keyboard when the user tabs out of the TextField
          splashColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: const Alignment(1.0, 1.0),
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Add a comment...',
                      ),
                      focusNode: _focusNode,
                      controller: _inputController,
                    ),
                    RaisedButton(
                      child: Text("Post"),
                      onPressed: () => {postComment()},
                    )
                  ],
                )
              ],
            ),
          ),
        );
      } else {
        return InkWell(
          // to dismiss the keyboard when the user tabs out of the TextField
          splashColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: const Alignment(1.0, 1.0),
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Add a comment...',
                      ),
                      focusNode: _focusNode,
                      controller: _inputController,
                    ),
                    RaisedButton(
                      child: Text("Post"),
                      onPressed: () => {postComment()},
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    }

    Future<void> _deleteComment(int index) async {
    InstagramBloc bloc = Provider.of<InstagramBloc>(context);
    CommentsBloc commentsBloc = Provider.of<CommentsBloc>(context);

    final res = await http.delete(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/comments/${commentsBloc.postComments[index].id}",
        headers: {HttpHeaders.authorizationHeader: "Bearer ${bloc.token}"});

    if (res.statusCode == 204) {
      log("comment deleted");
      setState(() {
        commentsBloc.postComments.removeAt(index);
        
      });
    } else {
      log("There was an erro trying to delete the comment");
    }
  }

    Widget commentList(int index) {

      InstagramBloc bloc = Provider.of<InstagramBloc>(context);
      CommentsBloc commentsBloc = Provider.of<CommentsBloc>(context);
      int user_id = commentsBloc.postComments[index].user_id;

      
      if (commentsBloc.usersMap[user_id].profile_image_url == null) {
        commentsBloc.usersMap[user_id].profile_image_url =
            "https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg";
      }

      //If is my Post or my comment, make it Slidable (To Delete)

      if (commentsBloc.postComments[index].user_id ==
              bloc.myAccount.id ||
          commentsBloc.post.user_id == bloc.myAccount.id) {
        return Slidable(
          actionPane: new SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
            child: Row(
              children: <Widget>[
                Container(
                    width: 40.0,
                    height: 40.0,
                    margin: EdgeInsets.all(9.0),
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(commentsBloc
                                .usersMap[user_id].profile_image_url)))),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                        text: '',
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: commentsBloc.usersMap[user_id].email + "  ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: commentsBloc.postComments[index].text,
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => {
                _deleteComment(index),
              },
            ),
          ],
        );
      }

      // if(widget.comment.id)

      return Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
        child: Row(
          children: <Widget>[
            Container(
                width: 40.0,
                height: 40.0,
                margin: EdgeInsets.all(9.0),
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(commentsBloc
                            .usersMap[user_id].profile_image_url)))),
            Expanded(
              child: RichText(
                text: TextSpan(
                    text: '',
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: commentsBloc.usersMap[user_id].email + "  ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: commentsBloc.postComments[index].text,
                      ),
                    ]),
              ),
            ),
          ],
        ),
      );

      // return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context, bloc.postComments.length);
              },
              // tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 8.0, bottom: 10.0, top: 8.0, right: 8.0),
            child: userCaption(),
          ),
          Divider(color: Colors.black54),
          Expanded(
            child: FutureBuilder(
              future: bloc.getComments(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Container(
                    child: Center(child: Text("Loading...")),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return commentList(index);
                    },
                  );
                }
              },
            ),
            // child: ListView.builder(
            //   itemCount: bloc.postComments.length,
            //   itemBuilder: (_, i) {

            //     return CommentView(i);
            //   },
            // ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: commentBox(),
          )
        ],
      ),
    );
  }
}