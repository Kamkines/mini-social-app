import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './post_detail_screen.dart';
import '../models/post.dart';
import '../providers/user_provider.dart';

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
              child: Text('Create a post'),
            ),
          ],
        ),
      ),
    );
  }

  void _createPostFunction() async {
    final user = context.read<UserProvider>().user;

    if (user == null) {
      return;
    }

    final titleText = _titlePostContoller.text;
    final postText = _postController.text;

    final postData = {
      'userId': FirebaseFirestore.instance.collection('users').doc(user.uid),
      'title': titleText,
      'description': postText,
      'date': FieldValue.serverTimestamp(), // встроенный метод из Firebase Cloud (подключен cloud_firestore). Устанавливает серверное время в поле и сохраняет его в формате TimeStamp
    };

    try {
      final newPostRef = await FirebaseFirestore.instance
          .collection('posts')
          .add(postData);


      final snapshot = await newPostRef.get(); // ждем, когда создастся запись в коллекции и берем уже данные оттуда. Нужно из-за разности в типах (Date/Timestamp)
      final newPost = Post.fromMap(snapshot.data()!, snapshot.id);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(post: newPost),
        ),
      );
    } catch (error, stackTrace) {
      print('Ошибка при создании поста: $error');
      print(stackTrace);
    }
  }
}
