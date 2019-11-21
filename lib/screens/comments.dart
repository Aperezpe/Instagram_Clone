import 'package:flutter/material.dart';
import 'package:instagram_clone/blocs/commentsBloc.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:instagram_clone/models/user.dart';
import "package:intl/intl.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/screens/loadingscreen.dart';
import 'package:instagram_clone/models/comment.dart';

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

    if (bloc.userAccount.profile_image_url == null) {
      bloc.userAccount.profile_image_url =
          "https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg";
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
                SizedBox(height: 300),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Add a comment...',
                  ),
                  focusNode: _focusNode,
                ),
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
                SizedBox(height: _animation.value),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Add a comment...',
                  ),
                  focusNode: _focusNode,
                )
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
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
            child: ListView.builder(
              itemCount: bloc.postComments.length,
              itemBuilder: (_, i) {
                Comment c = bloc.postComments[i];
                User u = bloc.usersMap[bloc.postComments[i].user_id];

                return CommentView(c, u);
              },
            ),
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

class CommentView extends StatelessWidget {
  final Comment comment;
  final User user;

  const CommentView(this.comment, this.user);

  @override
  Widget build(BuildContext context) {
    if (user.profile_image_url == null) {
      user.profile_image_url =
          "https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg";
    }

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
                      image: NetworkImage(user.profile_image_url)))),
          Expanded(
            child: RichText(
              text: TextSpan(
                  text: '',
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: user.email + "  ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: comment.text,
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
