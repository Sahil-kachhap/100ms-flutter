//Package imports
import 'dart:io';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hmssdk_flutter_example/hls_viewer/hls_viewer.dart';

//Project imports
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:hmssdk_flutter_example/common/constant.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/chat_bottom_sheet.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/offline_screen.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/video_tile.dart';
import 'package:hmssdk_flutter_example/common/util/utility_components.dart';
import 'package:hmssdk_flutter_example/enum/meeting_flow.dart';
import 'package:hmssdk_flutter_example/logs/custom_singleton_logger.dart';
import 'package:hmssdk_flutter_example/meeting/meeting_store.dart';
import 'package:hmssdk_flutter_example/meeting/peer_track_node.dart';
import 'package:provider/provider.dart';

// ignore: implementation_imports
import 'package:provider/src/provider.dart';
import 'meeting_participants_list.dart';

class MeetingPage extends StatefulWidget {
  final String roomId;
  final MeetingFlow flow;
  final String user;

  const MeetingPage(
      {Key? key, required this.roomId, required this.flow, required this.user})
      : super(key: key);

  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> with WidgetsBindingObserver {
  CustomLogger logger = CustomLogger();
  int appBarIndex = 0;
  bool raisedHand = false;
  bool audioViewOn = false;
  int countOfVideoOnBetweenTwo = 1;
  bool videoPreviousState = false;
  bool isRecordingStarted = false;
  bool isBRB = false;
  late MeetingStore meetingsStoreInstance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    meetingsStoreInstance = MeetingStore();
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => meetingsStoreInstance)],
    );
    initMeeting();
    checkButtons();
  }

  void initMeeting() async {
    bool ans =
        await context.read<MeetingStore>().join(widget.user, widget.roomId);
    if (!ans) {
      UtilityComponents.showSnackBarWithString("Unable to Join", context);
      Navigator.of(context).pop();
    }
    context.read<MeetingStore>().addUpdateListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkButtons();
  }

  void checkButtons() async {
    context.read<MeetingStore>().isVideoOn = !(await context
        .read<MeetingStore>()
        .isVideoMute(context.read<MeetingStore>().localPeer));
    context.read<MeetingStore>().isMicOn = !(await context
        .read<MeetingStore>()
        .isAudioMute(context.read<MeetingStore>().localPeer));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleMenu(int value) async {
    switch (value) {
      case 1:
        // StaticLogger.logger?.d(
        //     "\n----------------------------Sending Logs-----------------\n");
        // StaticLogger.logger?.close();
        // ShareExtend.share(CustomLogger.file?.path ?? '', 'file');
        // logger.getCustomLogger();
        UtilityComponents.showSnackBarWithString("Coming Soon...", context);
        break;

      case 2:
        if (context.watch<MeetingStore>().isRecordingStarted) {
          meetingsStoreInstance.stopRtmpAndRecording();
          isRecordingStarted = false;
        } else {
          if (isRecordingStarted == false) {
            String url = await UtilityComponents.showInputDialog(
                context: context,
                placeholder: "Enter RTMP Url",
                prefilledValue: Constant.rtmpUrl);
            if (url.isNotEmpty) {
              meetingsStoreInstance.startRtmpOrRecording(
                  meetingUrl: url, toRecord: true, rtmpUrls: null);
              isRecordingStarted = true;
            }
          }
        }
        break;

      case 3:
        if (context.watch<MeetingStore>().isVideoOn)
          meetingsStoreInstance.switchCamera();

        break;
      case 4:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ParticipantsList(),
          ),
        );
        break;
      case 5:
        // audioViewOn = !audioViewOn;
        // if (audioViewOn) {
        //   countOfVideoOnBetweenTwo = 0;
        //   _meetingStore.trackStatus.forEach((key, value) {
        //     _meetingStore.trackStatus[key] = HMSTrackUpdate.trackMuted;
        //   });
        //   videoPreviousState = _meetingStore.isVideoOn;
        //   _meetingStore.isVideoOn = false;
        //   _meetingStore.setPlayBackAllowed(false);
        // } else {
        //   _meetingStore.peerTracks.forEach((element) {
        //     _meetingStore.trackStatus[element.peerId] =
        //         element.track?.isMute ?? false
        //             ? HMSTrackUpdate.trackMuted
        //             : HMSTrackUpdate.trackUnMuted;
        //   });
        //   _meetingStore.setPlayBackAllowed(true);
        //   if (countOfVideoOnBetweenTwo == 0) {
        //     _meetingStore.isVideoOn = videoPreviousState;
        //   } else
        //     _meetingStore.isVideoOn =
        //         !(_meetingStore.localTrack?.isMute ?? true);
        // }
        // setState(() {});
        break;
      case 6:
        // if (!_meetingStore.isActiveSpeakerMode) {
        //   _meetingStore.setActiveSpeakerList();
        //   _meetingStore.isActiveSpeakerMode = true;
        //   UtilityComponents.showSnackBarWithString(
        //       "Active Speaker Mode", context);
        // } else {
        //   _meetingStore.activeSpeakerPeerTrackNodeList.clear();
        //   _meetingStore.isActiveSpeakerMode = false;
        // }
        UtilityComponents.showSnackBarWithString("Coming Soon...", context);
        break;
      case 7:
        // if (_meetingStore.isActiveSpeakerMode) {
        //   _meetingStore.isActiveSpeakerMode = false;
        //   setState(() {});
        //   UtilityComponents.showSnackBarWithString(
        //       "Switched to Hero Mode", context);
        // }
        UtilityComponents.showSnackBarWithString("Coming Soon...", context);
        break;
      case 8:
        String name = await UtilityComponents.showInputDialog(
            context: context, placeholder: "Enter Name");
        if (name.isNotEmpty) {
          meetingsStoreInstance.changeName(name: name);
        }
        break;
      case 9:
        if (context.watch<MeetingStore>().hasHlsStarted) {
          meetingsStoreInstance.stopHLSStreaming();
        } else {
          String url = await UtilityComponents.showInputDialog(
              context: context,
              placeholder: "Enter HLS Url",
              prefilledValue: Constant.rtmpUrl);
          if (url.isNotEmpty) {
            meetingsStoreInstance.startHLSStreaming(url);
          }
        }
        break;

      case 10:
        List<HMSRole> roles = await meetingsStoreInstance.getRoles();
        List<HMSRole> selectedRoles =
            await UtilityComponents.showRoleList(context, roles);
        if (selectedRoles.isNotEmpty)
          meetingsStoreInstance.changeTrackStateForRole(true, selectedRoles);
        break;
      case 11:
        meetingsStoreInstance.changeTrackStateForRole(true, null);
        break;
      case 12:
        meetingsStoreInstance.changeMetadataBRB();
        raisedHand = false;
        isBRB = !isBRB;
        break;
      case 13:
        meetingsStoreInstance.endRoom(false, "Room Ended From Flutter");
        if (context.watch<MeetingStore>().isRoomEnded) {
          Navigator.pop(context);
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = (size.width - 12) / 2;

    return ConnectivityAppWrapper(
        app: WillPopScope(
      child: ConnectivityWidgetWrapper(
          disableInteraction: true,
          offlineWidget: OfflineWidget(),
          child: context.select<MeetingStore, bool>(
                  (meetingStore) => meetingStore.reconnecting)
              ? OfflineWidget()
              : Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: Text(Constant.meetingCode),
                    actions: [
                      context.select<MeetingStore, bool>(
                              (meetingStore) => meetingStore.isRecordingStarted)
                          ? Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 2, color: Colors.red.shade600)),
                              child: Icon(
                                Icons.circle,
                                color: Colors.red,
                                size: 15,
                              ),
                            )
                          : Container(),
                      IconButton(
                        iconSize: 32,
                        onPressed: () {
                          context.read<MeetingStore>().toggleSpeaker();
                        },
                        icon: Icon(context.select<MeetingStore, bool>(
                                (meetingStore) => meetingStore.isSpeakerOn)
                            ? Icons.volume_up
                            : Icons.volume_off),
                      ),
                      PopupMenuButton(
                        icon: Icon(CupertinoIcons.gear),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Send Logs",
                                    style: TextStyle(color: Colors.blue)),
                                Icon(Icons.bug_report, color: Colors.blue),
                              ],
                            ),
                            value: 1,
                          ),
                          if (context.select<MeetingStore, bool>(
                              (meetingStore) => meetingStore
                                  .localPeer!.role.name
                                  .contains("hls-")))
                            PopupMenuItem(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        context.select<MeetingStore, bool>(
                                                (meetingStore) => meetingStore
                                                    .isRecordingStarted)
                                            ? "Recording "
                                            : "Record",
                                        style: TextStyle(
                                          color: context.select<MeetingStore,
                                                      bool>(
                                                  (meetingStore) => meetingStore
                                                      .isRecordingStarted)
                                              ? Colors.red
                                              : Colors.blue,
                                        )),
                                    Icon(
                                      Icons.circle,
                                      color: context.select<MeetingStore, bool>(
                                              (meetingStore) => meetingStore
                                                  .isRecordingStarted)
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                  ]),
                              value: 2,
                            ),
                          if (!context.select<MeetingStore, bool>(
                              (meetingStore) => meetingStore
                                  .localPeer!.role.name
                                  .contains("hls-")))
                            PopupMenuItem(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Toggle Camera  ",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    Icon(Icons.switch_camera,
                                        color: Colors.blue),
                                  ]),
                              value: 3,
                            ),
                          PopupMenuItem(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Participants  ",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  Icon(CupertinoIcons.person_3_fill,
                                      color: Colors.blue),
                                ]),
                            value: 4,
                          ),
                          PopupMenuItem(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    audioViewOn ? "Video View" : "Audio View",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  Image.asset(
                                    audioViewOn
                                        ? 'assets/icons/video.png'
                                        : 'assets/icons/audio.png',
                                    color: Colors.blue,
                                    height: 24.0,
                                    width: 24.0,
                                  ),
                                ]),
                            value: 5,
                          ),
                          PopupMenuItem(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Active Speaker Mode ",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  Icon(CupertinoIcons.person_3_fill,
                                      color: Colors.blue),
                                ]),
                            value: 6,
                          ),
                          PopupMenuItem(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Hero Mode ",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  Icon(CupertinoIcons.person_3_fill,
                                      color: Colors.blue),
                                ]),
                            value: 7,
                          ),
                          PopupMenuItem(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Change Name",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  Icon(Icons.create_rounded,
                                      color: Colors.blue),
                                ]),
                            value: 8,
                          ),
                          if (!context.select<MeetingStore,bool>((meetingStore) => meetingStore.localPeer!.role.name
                              .contains("hls-")))
                            PopupMenuItem(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.select<MeetingStore,bool>((meetingStore) => meetingStore.hasHlsStarted)
                                          ? "Stop HLS"
                                          : "Start HLS",
                                      style: TextStyle(
                                        color: context.select<MeetingStore,bool>((meetingStore) => meetingStore.hasHlsStarted)
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                                    ),
                                    Icon(Icons.stream, color: Colors.blue),
                                  ]),
                              value: 9,
                            ),
                          if (context.select<MeetingStore,bool>((meetingStore) => meetingStore.localPeer?.role.permissions.changeRole ??
                              false))
                            PopupMenuItem(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Mute Roles",
                                      style: TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Icon(Icons.mic_off_sharp,
                                        color: Colors.blue),
                                  ]),
                              value: 10,
                            ),
                          if (context.select<MeetingStore,bool>((meetingStore) => meetingStore
                                  .localPeer?.role.permissions.changeRole ??
                              false))
                            PopupMenuItem(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Mute All",
                                      style: TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Icon(Icons.mic_off, color: Colors.blue),
                                  ]),
                              value: 11,
                            ),
                          PopupMenuItem(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "BRB",
                                    style: TextStyle(
                                        color:
                                            isBRB ? Colors.red : Colors.blue),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: isBRB
                                                ? Colors.red
                                                : Colors.blue)),
                                    child: Text(
                                      "BRB",
                                      style: TextStyle(
                                          color:
                                              isBRB ? Colors.red : Colors.blue),
                                    ),
                                  ),
                                ]),
                            value: 12,
                          ),
                          if (context.select<MeetingStore,bool>((meetingStore) => meetingStore.localPeer!.role.permissions.endRoom!))
                            PopupMenuItem(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "End Room",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    Icon(Icons.cancel_schedule_send,
                                        color: Colors.blue),
                                  ]),
                              value: 13,
                            ),
                        ],
                        onSelected: handleMenu,
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                            child: (!context.select<MeetingStore,bool>((meetingStore) => meetingStore.isHLSLink))
                                ? (context.select<MeetingStore,bool>((meetingStore) => meetingStore.peerTracks.isEmpty))
                                    ? Center(
                                        child:
                                            Text('Waiting for others to join!'))
                                    : MasonryGridView.count(
                                      cacheExtent: 1,
                                        scrollDirection: Axis.horizontal,
                                        physics: PageScrollPhysics(),
                                        itemCount:
                                            context.select<MeetingStore,int>((meetingStore) => meetingStore.peerTracks.length),
                                        crossAxisCount: 2,
                                        itemBuilder: (ctx, index) {
                                          return ListenableProvider.value(
                                            value: context.read<MeetingStore>().peerTracks[index],
                                            child: VideoTile(
                                                  itemHeight: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  itemWidth: itemWidth,
                                                  audioView: audioViewOn,
                                                  index : index,
                                                  peerTrackNode: context.read<MeetingStore>().peerTracks[index]
                                                ),
                                          );
                                        },
                                      )
                                : SizedBox()),
                        (context.select<MeetingStore,bool>((meetingStore) => meetingStore.isHLSLink))
                            ? (context.select<MeetingStore,bool>((meetingStore) => meetingStore.hasHlsStarted))
                                ? Flexible(
                                    child: Center(
                                      child: Container(
                                        child: HLSViewer(
                                            streamUrl: context.select<MeetingStore,String>((meetingStore) => meetingStore.streamUrl)),
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Waiting for HLS to start...",
                                    style: TextStyle(fontSize: 30),
                                  )
                            : SizedBox()
                      ],
                    ),
                  ),
                  bottomNavigationBar: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (context.select<MeetingStore,bool>((meetingStore) => meetingStore.localPeer != null) &&
                            context.select<MeetingStore,bool>((meetingStore) => meetingStore.localPeer!.role.publishSettings!.allowed
                                .contains("video")))
                          Container(
                              padding: EdgeInsets.all(8),
                              child: IconButton(
                                  tooltip: 'Video',
                                  iconSize: 32,
                                  onPressed: (audioViewOn)
                                      ? null
                                      : () {
                                          context
                                              .read<MeetingStore>()
                                              .switchVideo();
                                          countOfVideoOnBetweenTwo++;
                                        },
                                  icon: Icon(context.select<MeetingStore,bool>((meetingStore) => meetingStore.isVideoOn)
                                      ? Icons.videocam
                                      : Icons.videocam_off))),
                        if (context.select<MeetingStore,bool>((meetingStore) => meetingStore.localPeer != null) &&
                            context.select<MeetingStore,bool>((meetingStore) => meetingStore.
                                localPeer!.role.publishSettings!.allowed
                                .contains("audio")))
                          Container(
                              padding: EdgeInsets.all(8),
                              child: IconButton(
                                  tooltip: 'Audio',
                                  iconSize: 32,
                                  onPressed: () {
                                    context.read<MeetingStore>().switchAudio();
                                  },
                                  icon: Icon(context.select<MeetingStore,bool>((meetingStore) => meetingStore.isMicOn)
                                      ? Icons.mic
                                      : Icons.mic_off))),
                        Container(
                            padding: EdgeInsets.all(8),
                            child: IconButton(
                              tooltip: 'RaiseHand',
                              iconSize: 32,
                              onPressed: () {
                                setState(() {
                                  raisedHand = !raisedHand;
                                  isBRB = false;
                                });
                                context.read<MeetingStore>().changeMetadata();
                                UtilityComponents.showSnackBarWithString(
                                    raisedHand
                                        ? "Raised Hand ON"
                                        : "Raised Hand OFF",
                                    context);
                              },
                              icon: Image.asset(
                                'assets/icons/raise_hand.png',
                                color: raisedHand
                                    ? Colors.amber.shade300
                                    : Colors.black,
                              ),
                            )),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: IconButton(
                              tooltip: 'Chat',
                              iconSize: 32,
                              onPressed: () {
                                // chatMessages(context, _meetingStore);
                              },
                              icon: Icon(Icons.chat_bubble)),
                        ),
                        if (context.select<MeetingStore,bool>((meetingStore) => meetingStore.localPeer != null) &&
                            context.select<MeetingStore,bool>((meetingStore) => meetingStore.
                                localPeer!.role.publishSettings!.allowed
                                .contains("screen")) &&
                            Platform.isAndroid)
                          Container(
                            padding: EdgeInsets.all(8),
                            child: IconButton(
                                tooltip: 'Share',
                                iconSize: 32,
                                onPressed: () {
                                  if (!context.select<MeetingStore,bool>((meetingStore) => meetingStore.isScreenShareOn)) {
                                    context
                                        .read<MeetingStore>()
                                        .startScreenShare();
                                  } else {
                                    context
                                        .read<MeetingStore>()
                                        .stopScreenShare();
                                  }
                                },
                                icon: Icon(
                                  Icons.screen_share,
                                  color: context.select<MeetingStore,bool>((meetingStore) => meetingStore.isScreenShareOn)
                                      ? Colors.blue
                                      : Colors.black,
                                )),
                          ),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: IconButton(
                              color: Colors.red,
                              tooltip: 'Leave Or End',
                              iconSize: 32,
                              onPressed: () async {
                                await UtilityComponents.onBackPressed(context);
                              },
                              icon: Icon(Icons.call_end)),
                        ),
                      ]),
                )),
      onWillPop: () async {
        bool ans = await UtilityComponents.onBackPressed(context) ?? false;
        return ans;
      },
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    final _readMeetingStore = context.read<MeetingStore>();
    final _watchMeetingStore = context.watch<MeetingStore>();
    if (state == AppLifecycleState.resumed) {
      if (_watchMeetingStore.isVideoOn) {
        _readMeetingStore.startCapturing();
      } else {
        _readMeetingStore.stopCapturing();
      }
    } else if (state == AppLifecycleState.paused) {
      if (_watchMeetingStore.isVideoOn) {
        _readMeetingStore.stopCapturing();
      }
    } else if (state == AppLifecycleState.inactive) {
      if (_watchMeetingStore.isVideoOn) {
        _readMeetingStore.stopCapturing();
      }
    }
  }
}
