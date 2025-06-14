import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mini_social_app/providers/provider.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // с помощью этой команды мы запускаем Flutter заранее, нужно для установки асинхронных связей
  await Firebase.initializeApp(); // устанавливаем Firebase
  runApp(
    MultiProvider( // MultiProvider — обёртка, чтобы не вкладывать кучу ChangeNotifierProvider друг в друга
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (_) => CommentsProvider(),
        ), // добавляем кэш комментариев
      ],
      child: const MyApp(),
    ), // ChangeNotifierProvider - это инструмент библиотеки Provider Flutter. Помогает в регистрации провайдера для апки
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeSport',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(),
    );
  }
}

/*


*/

/* 
Файл, точка входа

Передача по сути как в React, только необязательно передавать четко какой класс ты передаешь, ибо в Dart все само найдется
по сути тут все выглядит так 
import * путь

!!! Если класс назывался _Name, то он был бы приватным и его нельзя было бы импортировать 
*/
