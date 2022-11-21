//Package imports
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pip_flutter/pipflutter_player.dart';
import 'package:pip_flutter/pipflutter_player_controller.dart';
import 'package:provider/provider.dart';

//Project imports
import 'package:hmssdk_flutter_example/data_store/meeting_store.dart';

class HLSPlayer extends StatefulWidget {
  final String streamUrl;

  HLSPlayer({Key? key, required this.streamUrl}) : super(key: key);

  @override
  _HLSPlayerState createState() => _HLSPlayerState();
}

class _HLSPlayerState extends State<HLSPlayer> {
  @override
  void initState() {
    super.initState();
    context.read<MeetingStore>().setPIPVideoController(widget.streamUrl, false);
    // context.read<MeetingStore>().hlsVideoController =
    //     VideoPlayerController.network(
    //   widget.streamUrl,
    // )..initialize().then((_) {
    //         context.read<MeetingStore>().hlsVideoController!.play();
    //         setState(() {});
    //       });
  }

  @override
  void dispose() async {
    super.dispose();
    try {
      context.read<MeetingStore>().hlsVideoController?.dispose();
      context.read<MeetingStore>().hlsVideoController = null;
    } catch (e) {
      //To handle the error when the user calls leave from hls-viewer role.
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MeetingStore, PipFlutterPlayerController?>(
        selector: (_, meetingStore) => meetingStore.hlsVideoController,
        builder: (_, controller, __) {
          if (controller == null) {
            return Scaffold();
          }
          return Scaffold(
              key: GlobalKey(),
              floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: Text(
                    "LIVE",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    context
                        .read<MeetingStore>()
                        .setPIPVideoController(widget.streamUrl, true);
                  }),
              body: Center(
                  child: AspectRatio(
                aspectRatio: 16 / 9,
                child: PipFlutterPlayer(
                  controller: controller,
                  key: context.read<MeetingStore>().pipFlutterPlayerKey,
                ),
              )));
        });
  }
}
