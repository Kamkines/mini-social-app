import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart';

class PostCreateScreen extends StatefulWidget {
  @override
  _PostCreateScreenState createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final TextEditingController _titlePostContoller = TextEditingController();
  final TextEditingController _postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titlePostContoller,
          decoration: InputDecoration(
            hintText: '* Add post titles',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: '* Add text post',
                border: OutlineInputBorder(),
              ),
            ),
            TextButton(
              onPressed: () {
                _createPostFunction();
              }, 
              child: Text('Create a post')
              )
          ],
        ),
      ),
    );
  }

  void _createPostFunction() async {
    User? user = FirebaseAuth.instance.currentUser;

    if(user == null){
      return;
    }

    final titleText = _titlePostContoller.text;
    final postText = _postController.text;

    final postData = {
      'userId': user.uid,
      'title': titleText,
      'description': postText,
      'date': DateTime.now()
    };

    await FirebaseFirestore.instance.collection('posts').add(postData);
    print('Post added');
  }
}

