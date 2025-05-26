import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:custom_video_player/custom_video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Coaching Videos',
      home: MyHomePage(title: 'Discover'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;

  final String videoUrl =
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) => setState(() {}));

    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController,
    );
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  Widget tabItem(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Horizontal Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  tabItem("Coach smarter"),
                  tabItem("How to..."),
                  tabItem("Beyond limits"),
                  tabItem("Body capabilities"),
                  tabItem("Motivation"),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Main Video Player
            Text(
              "Coach smarter not harder",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              SizedBox(height: 10),
              Video.network(
                'https://youtu.be/JVQOA-w34M8',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            CustomVideoPlayer(
              customVideoPlayerController: _customVideoPlayerController,
            ),
            SizedBox(height: 20),


            Text(
              "Smart coaching backed by science",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Video.network(
              'https://youtu.be/qArnG6a-FzY',
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text(
              "How to coach for success",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Video.network(
              'https://youtu.be/J1qiCdrXHgU',
              height: 200,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
