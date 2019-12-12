import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/models/comment.dart';
// import 'package:instagram_clone/screens/userProfile.dart';
//import 'package:instagram_clone/blocs/instagrambloc.dart';

//From instagrambloc I can get the token

class CommentsBloc extends ChangeNotifier {
  bool isReady = false;
  // bool isLoggedIn = false;
  // bool didLoginFail = false;
  bool didLoadFail = false;
  Post post;
  // int postId;
  // int user_id;
  //List<Post> timeline = [];
  List<Comment> postComments = [];
  // List<User> users = [];//
  Map<int, User> usersMap = {};
  // List<User> users;
  User userAccount;
  User myAccount;
  String token;
  String caption;

  CommentsBloc(this.post) {
    caption = post.caption;
    setup();
  }

  Future<void> setup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    token = (prefs.getString('token') ?? null);
    print("User token: " + token);
    if (token != null) {
      notifyListeners();
      loadData();
    }
  }

  Future<void> loadData() async {
    // bool fetchedTimeline = await fetchTimeline();
    //bool fetchMyAccount = await fetchMyAccount();
    bool fetchedComments = await fetchComments();
    bool fetchAccount = await fetchAccounts();
    //bool fetchedAccount = await fetchUserAccounts();
    if (fetchedComments && fetchAccount) {
      print("Comments are ready");
      isReady = true;
      notifyListeners();
    } else {
      print("Comments are not ready");
      didLoadFail = true;
      notifyListeners();
    }
  }


  Future<bool> fetchComments() async {
    print("getting user data #comments");
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/${post.id}/comments",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    if (response.statusCode == 200) {
      List<dynamic> serverComments = json.decode(response.body);
      for (int i = 0; i < serverComments.length; ++i) {
        postComments.add(Comment.fromJson(serverComments[i]));

        var userResponse = await http.get(
            "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/${postComments[i].user_id}",
            headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
        if (userResponse.statusCode==200){
          print("user ${postComments[i].user_id} retrieved successfully");

          
          usersMap[postComments[i].user_id] = User.fromJson(jsonDecode(userResponse.body));
          // users.add(User.fromJson(jsonDecode(userResponse.body)));
        }else{
          print("problemas obteniendo usuario por comentario");
        }

      }
      return true;
    }else{
      print("problema obteniendo comments map");
    }
    return false;
  }

  Future<dynamic> getComments() async {

    List<Comment> listComments = [];
    
    log("getting user data #comments");
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/posts/${post.id}/comments",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 200) {
      List<dynamic> serverComments = json.decode(response.body);
      for (int i = 0; i < serverComments.length; ++i) {
        listComments.add(Comment.fromJson(serverComments[i]));

        var userResponse = await http.get(
            "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/${postComments[i].user_id}",
            headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
        if (userResponse.statusCode==200){
          log("user ${postComments[i].user_id} retrieved successfully");

          
          usersMap[listComments[i].user_id] = User.fromJson(jsonDecode(userResponse.body));
          // users.add(User.fromJson(jsonDecode(userResponse.body)));
        }else{
         log("problemas obteniendo usuario por comentario");
        }

      }
      postComments = listComments;
      return listComments;
    }else{
      log("problema obteniendo comments map");
    }
    return null;
  }

  Future<bool> fetchAccounts() async {
    print("getting user data #comments");
    var response = await http.get(
        "https://nameless-escarpment-45560.herokuapp.com/api/v1/users/${post.user_id}",
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    if (response.statusCode == 200) {
      userAccount = User.fromJson(json.decode(response.body));

      print("getting my account data #Comments");
      var myAccountResponse = await http.get(
          "https://nameless-escarpment-45560.herokuapp.com/api/v1/my_account",
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      if (myAccountResponse.statusCode == 200) {
        myAccount = User.fromJson(json.decode(myAccountResponse.body));
        return true;
      }
    } else {
      print(response.body);
      print("user account load failed");
    }
    return false;
  }
}
