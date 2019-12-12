import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/main.dart' as prefix0;
// import 'package:instagram_clone/blocs/instagrambloc.dart';
// import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:instagram_clone/screens/mainscreen.dart';
import 'package:instagram_clone/screens/onePost.dart';
import 'dart:io';
import 'package:instagram_clone/screens/myProfileScreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:instagram_clone/screens/loadingscreen.dart';
import 'package:instagram_clone/blocs/userProfileBloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'newPost.dart';

class UserProfile extends StatefulWidget {
  final int user_id;

  const UserProfile(this.user_id);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    UserProfileBloc bloc = UserProfileBloc(widget.user_id);
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
    UserProfileBloc bloc = Provider.of<UserProfileBloc>(context);

    if (bloc.isReady) {
      return UserProfileScreen();
    } else {
      return LoadingScreen();
    }
  }
}

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int screen = 0;

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
    UserProfileBloc bloc = Provider.of<UserProfileBloc>(context);
    User userAccount = bloc.userAccount;

    if (userAccount.profile_image_url == null) {
      userAccount.profile_image_url =
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

    Widget userBio() {
      String bio = "";
      if(userAccount.bio!=null){
        bio = userAccount.bio;
      }
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15.0, bottom:15.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(bio)
              ),
          ),
        ],
      );
    }

    Widget userProfileHeader() {
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
                      image: new NetworkImage(userAccount.profile_image_url)))),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: CircleAvatar(
          //     radius: 20,
          //     // backgroundImage: NetworkImage("https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg"),
          //     backgroundColor: Colors.blue,
          //   ),
          // ),
          postsMsg(bloc.user_posts.length),
        ],
      );
    }

    Card getStructuredGridCell(Post post) {
      return Card(
          elevation: 1.5,
          child: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OnePost(post)));
            },
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: post.image_url,
                      placeholder: (context, url) => Row(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  )
                ]),
          ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(bloc.userAccount.email),
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
            } else if (i == 4) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyProfile()));
            }else if (i == 2) {
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
            userProfileHeader(),
            userBio(),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(bloc.user_posts.length, (index) {
                  return getStructuredGridCell(bloc.user_posts[index]);
                }),
              ),
            )
          ],
        ));
  }
}

// class UserProfile extends StatefulWidget {
//   final int user_id;

//   const UserProfile(this.user_id);

//   @override
//   _UserProfileState createState() => _UserProfileState();
// }

// class _UserProfileState extends State<UserProfile> {
//   int screen = 0;

//   // TextEditingController usernameCtrl = TextEditingController();
//   // TextEditingController passwordCtrl = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     InstagramBloc bloc = Provider.of<InstagramBloc>(context);

//     Future<User> _fetchUserAccount() async {
//       var user;
//       var response = await http.get(
//           "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/${widget.user_id}",
//           headers: {HttpHeaders.authorizationHeader: "Bearer ${bloc.token}"});
//       if (response.statusCode == 200) {
//         user = User.fromJson(json.decode(response.body));
//       } else {
//         print(response.body);
//         print("account load failed");
//       }
//       return user;
//     }

//     Future<List<Post>> getPosts() async {
//       var user_posts;
//       var user_posts_response = await http.get(
//           "https://nameless-escarpment-45560.herokuapp.com/api/v1/my_posts",
//           headers: {HttpHeaders.authorizationHeader: "Bearer ${bloc.token}"});

//       if (user_posts_response.statusCode == 200) {
//         print("successfully got account posts");
//         List<dynamic> server_posts = json.decode(user_posts_response.body);
//         user_posts = server_posts.map((p) => Post.fromJson(p)).toList();
//       }

//       return user_posts;
//     }

//     Widget postMsg(int count) {
//       String msg = "";

//       if (count > 1) {
//         msg += "Posts";
//       } else {
//         msg += "Post";
//       }

//       return Column(
//         children: <Widget>[Text(count.toString()), Text(msg)],
//       );
//     }

//     Widget profileUserHeader() {
//       Widget message = postMsg(2);

//       return FutureBuilder<User>(
//         future: _fetchUserAccount(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Text(
//               "Tere was an error :(",
//               style: Theme.of(context).textTheme.headline,
//             );
//           } else if (snapshot.hasData) {
//             return Row(
//               children: <Widget>[
//                 Container(
//                     width: 70.0,
//                     height: 70.0,
//                     margin: EdgeInsets.all(20.0),
//                     decoration: new BoxDecoration(
//                         shape: BoxShape.circle,
//                         image: new DecorationImage(
//                             fit: BoxFit.cover,
//                             image: new NetworkImage(snapshot.data.profile_image_url)))),
//                 // Padding(
//                 //   padding: const EdgeInsets.all(8.0),
//                 //   child: CircleAvatar(
//                 //     radius: 20,
//                 //     // backgroundImage: NetworkImage("https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg"),
//                 //     backgroundColor: Colors.blue,
//                 //   ),
//                 // ),
//                 message,
//               ],
//             );
//           } else {
//             return Row(); // Blank screen Loading
//           }
//         },
//       );
//     }

//     // if (myAccount.profile_image_url == null) {
//     //   myAccount.profile_image_url =
//     //       "https://instagram-prod.s3.amazonaws.com/1572465027-RackMultipart20191030-4-958dhn.png";
//     // }

//     Widget postsMsg(int count) {
//       String msg = "";

//       if (count > 1) {
//         msg += "Posts";
//       } else {
//         msg += "Post";
//       }

//       return Column(
//         children: <Widget>[Text(count.toString()), Text(msg)],
//       );
//     }

//     Widget profileHeader() {
//       return Row(
//         children: <Widget>[
//           // Container(
//           //     width: 70.0,
//           //     height: 70.0,
//           //     margin: EdgeInsets.all(20.0),
//           //     decoration: new BoxDecoration(
//           //         shape: BoxShape.circle,
//           //         image: new DecorationImage(
//           //             fit: BoxFit.cover,
//           //             image: new NetworkImage(myAccount.profile_image_url)))),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: CircleAvatar(
//               radius: 20,
//               // backgroundImage: NetworkImage("https://www.mbkeramika.cz/data/lide/43_o_thumb.jpg"),
//               backgroundColor: Colors.blue,
//             ),
//           ),
//           postsMsg(bloc.my_posts.length),
//         ],
//       );
//     }

//     Card getStructuredGridCell(Post post) {
//       return Card(
//           elevation: 1.5,
//           child: InkWell(
//             onTap: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => OnePost(post)));
//             },
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[Image.network(post.image_url)]),
//           ));
//     }

//     Future<String> _getUserEmail() async{
//       var user;
//       var response = await http.get(
//           "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/${widget.user_id}",
//           headers: {HttpHeaders.authorizationHeader: "Bearer ${bloc.token}"});
//       if (response.statusCode == 200) {
//         print("Got user name!");
//         user = User.fromJson(json.decode(response.body));
//       } else {
//         print(response.body);
//         print("account load failed");
//       }

//       return user.email;

//     }

//     return Scaffold(
//         appBar: AppBar(
//           title: FutureBuilder<String>(
//             future: _getUserEmail(),
//             builder: (context, snapshot){
//               if(snapshot.hasError){
//                 return Text("There was an error");
//               }else if(snapshot.hasData){
//                 return Text(snapshot.data);
//               }else{
//                 return Row();
//               }
//             }
//           ),
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: screen, // this will be set when a new tab is tapped
//           onTap: (int i) {
//             setState(() {
//               this.screen = i;
//             });
//             if (i == 0) {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => MainScreen()));
//             }
//           },

//           items: [
//             BottomNavigationBarItem(
//               icon: new Icon(MdiIcons.homeOutline, color: Colors.black87),
//               activeIcon: new Icon(MdiIcons.home, color: Colors.black87),
//               title: new Text(""),
//             ),
//             BottomNavigationBarItem(
//                 icon: new Icon(Icons.search),
//                 activeIcon: new Icon(Icons.search, color: Colors.black87),
//                 title: new Text("")),
//             BottomNavigationBarItem(
//                 icon: new Icon(
//                   MdiIcons.plusBoxOutline,
//                   color: Colors.black87,
//                 ),
//                 activeIcon: new Icon(MdiIcons.plusBox, color: Colors.black87),
//                 title: new Text("")),
//             BottomNavigationBarItem(
//                 icon: new Icon(
//                   MdiIcons.heartOutline,
//                   color: Colors.black87,
//                 ),
//                 activeIcon: new Icon(MdiIcons.heart, color: Colors.black87),
//                 title: new Text("")),
//             BottomNavigationBarItem(
//                 icon: new Icon(
//                   MdiIcons.accountOutline,
//                   color: Colors.black87,
//                 ),
//                 activeIcon: new Icon(MdiIcons.account, color: Colors.black87),
//                 title: new Text("")),
//           ],
//         ),
//         body: Column(
//           children: <Widget>[
//             profileUserHeader(),
//           ],
//         ));
//   }
// }

// // Column(
// //           children: <Widget>[
// //             profileHeader(),
// //             Expanded(
// //               child: GridView.count(
// //                 crossAxisCount: 3,
// //                 children: List.generate(bloc.my_posts.length, (index) {
// //                   return getStructuredGridCell(bloc.my_posts[index]);
// //                 }),
// //               ),
// //             )
// //           ],
// //         )
