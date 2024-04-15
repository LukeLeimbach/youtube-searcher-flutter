import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wall_music_flutter/firebase_options.dart';

import 'reorderable_list.dart';
import 'youtube_search.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WallMusicApp());
}

class WallMusicApp extends StatelessWidget {
  const WallMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        highlightColor: Colors.lightBlueAccent,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Wall Moment Music'),
          centerTitle: true,
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: MyReorderableList()),
            Expanded(child: YoutubeSearch()),
          ],
        ),
      ),
    );
  }
}