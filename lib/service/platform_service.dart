import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hmssdk_flutter/common/platform_methods.dart';
import 'package:hmssdk_flutter/enum/hms_peer_update.dart';
import 'package:hmssdk_flutter/enum/hms_room_update.dart';
import 'package:hmssdk_flutter/enum/hms_track_update.dart';
import 'package:hmssdk_flutter/enum/hms_update_listener_method.dart';
import 'package:hmssdk_flutter/model/hms_error.dart';
import 'package:hmssdk_flutter/model/hms_message.dart';
import 'package:hmssdk_flutter/model/hms_peer.dart';
import 'package:hmssdk_flutter/model/hms_preview_listener.dart';
import 'package:hmssdk_flutter/model/hms_role_change_request.dart';
import 'package:hmssdk_flutter/model/hms_room.dart';
import 'package:hmssdk_flutter/model/hms_speaker.dart';
import 'package:hmssdk_flutter/model/hms_track.dart';
import 'package:hmssdk_flutter/model/hms_update_listener.dart';
import 'package:hmssdk_flutter/model/platform_method_response.dart';

class PlatformService {
  static const MethodChannel _channel = const MethodChannel('hmssdk_flutter');
  static const EventChannel _meetingEventChannel =
      const EventChannel('meeting_event_channel');
  static List<HMSUpdateListener> meetingListeners = [];
  static List<HMSPreviewListener> previewListeners = [];
  static bool isStartedListening = false;

  static void addMeetingListener(HMSUpdateListener newListener) {
    meetingListeners.add(newListener);
  }

  static void removeMeetingListener(HMSUpdateListener listener) {
    if (meetingListeners.contains(listener)) meetingListeners.remove(listener);
  }

  static void addPreviewListener(HMSPreviewListener newListener) {
    previewListeners.add(newListener);
  }

  static void removePreviewListener(HMSPreviewListener listener) {
    if (previewListeners.contains(listener)) previewListeners.remove(listener);
  }

  static Future<dynamic> invokeMethod(PlatformMethod method,
      {Map? arguments}) async {
    if (!isStartedListening) {
      isStartedListening = true;
      updatesFromPlatform();
    }
    var result = await _channel.invokeMethod(
        PlatformMethodValues.getName(method), arguments);
    print(result);
    return result;
  }

  static void updatesFromPlatform() {
    // _meetingEventChannel.receiveBroadcastStream().listen((event) {
    //   print('bol hello');
    // });

    // _meetingEventChannel
    //     .receiveBroadcastStream()
    //     .map((event) => event)
    //     .listen((event) {
    //   print('bol hello kuster');
    // });

    _meetingEventChannel
        .receiveBroadcastStream()
        .map<HMSUpdateListenerMethodResponse>((event) {
      Map<String, dynamic>? data = {};
      if (event is Map && event['data'] is Map) {
        (event['data'] as Map).forEach((key, value) {
          data[key.toString()] = value;
        });
      }
      HMSUpdateListenerMethod method =
          HMSUpdateListenerMethodValues.getMethodFromName(event['event_name']);
      return HMSUpdateListenerMethodResponse(
          method: method, data: data, response: event);
    }).listen((event) {
      HMSUpdateListenerMethod method = event.method;
      Map data = event.data;
      switch (method) {
        case HMSUpdateListenerMethod.onJoinRoom:
          HMSRoom? room = HMSRoom.fromMap(data['room']);
          notifyListeners(method, {'room': room});
          break;
        case HMSUpdateListenerMethod.onUpdateRoom:
          HMSRoom? room = HMSRoom.fromMap(data['room']);
          HMSRoomUpdate? update =
              HMSRoomUpdateValues.getHMSRoomUpdateFromName(data['update']);
          notifyListeners(method, {'room': room, 'update': update});
          break;
        case HMSUpdateListenerMethod.onPeerUpdate:
          HMSPeer? peer = HMSPeer.fromMap(data['peer']);
          HMSPeerUpdate? update =
              HMSPeerUpdateValues.getHMSPeerUpdateFromName(data['update']);
          notifyListeners(method, {'peer': peer, 'update': update});
          break;
        case HMSUpdateListenerMethod.onTrackUpdate:
          HMSPeer? peer = HMSPeer.fromMap(event.data['peer']);
          HMSTrack? track = HMSTrack.fromMap(data['track'], peer);
          HMSTrackUpdate? update =
              HMSTrackUpdateValues.getHMSTrackUpdateFromName(data['update']);

          notifyListeners(
              method, {'track': track, 'peer': peer, 'update': update});
          break;
        case HMSUpdateListenerMethod.onError:
          HMSError error = HMSError.fromMap(data['error']);
          notifyListeners(method, {'error': error});
          break;
        case HMSUpdateListenerMethod.onMessage:
          HMSMessage message = HMSMessage.fromMap(data['message']);
          notifyListeners(method, {'message': message});
          break;
        case HMSUpdateListenerMethod.onUpdateSpeaker:
          List<HMSSpeaker> speakers = [];
          if (data.containsKey('speakers') && data['speakers'] is List) {
            (data['speakers'] as List)
                .map((e) => speakers.add(HMSSpeaker.fromMap(e)));
          }
          notifyListeners(method, {'speakers': speakers});
          break;
        case HMSUpdateListenerMethod.onReconnecting:
          notifyListeners(method, {});
          break;
        case HMSUpdateListenerMethod.onReconnected:
          notifyListeners(method, {});
          break;
        case HMSUpdateListenerMethod.onRoleChangeRequest:
          HMSRoleChangeRequest roleChangeRequest =
              HMSRoleChangeRequest.fromMap(data['role_change_request']);
          notifyListeners(method, {'role_change_request': roleChangeRequest});
          break;
        case HMSUpdateListenerMethod.unknown:
          print('Unknown method called');
          break;
      }
    });
  }

  static void notifyListeners(
      HMSUpdateListenerMethod method, Map<String, dynamic> arguments) {
    switch (method) {
      case HMSUpdateListenerMethod.onJoinRoom:
        meetingListeners.forEach((e) => e.onJoin(room: arguments['room']));
        break;
      case HMSUpdateListenerMethod.onUpdateRoom:
        meetingListeners.forEach((e) => e.onRoomUpdate(
            room: arguments['room'], update: arguments['update']));
        break;
      case HMSUpdateListenerMethod.onPeerUpdate:
        meetingListeners.forEach((e) => e.onPeerUpdate(
            peer: arguments['peer'], update: arguments['update']));
        break;
      case HMSUpdateListenerMethod.onTrackUpdate:
        meetingListeners.forEach((e) => e.onTrackUpdate(
            track: arguments['track'],
            trackUpdate: arguments['update'],
            peer: arguments['peer']));
        break;
      case HMSUpdateListenerMethod.onError:
        meetingListeners.forEach((e) => e.onError(error: arguments['error']));
        break;
      case HMSUpdateListenerMethod.onMessage:
        meetingListeners
            .forEach((e) => e.onMessage(message: arguments['message']));
        break;
      case HMSUpdateListenerMethod.onUpdateSpeaker:
        meetingListeners.forEach(
            (e) => e.onUpdateSpeakers(updateSpeakers: arguments['speakers']));
        break;
      case HMSUpdateListenerMethod.onReconnecting:
        meetingListeners.forEach((e) => e.onReconnecting());
        break;
      case HMSUpdateListenerMethod.onReconnected:
        meetingListeners.forEach((e) => e.onReconnected());
        break;
      case HMSUpdateListenerMethod.onRoleChangeRequest:
        meetingListeners.forEach((e) => e.onRoleChangeRequest(
            roleChangeRequest: arguments['role_change_request']));
        break;
      case HMSUpdateListenerMethod.unknown:
        break;
    }
  }
}
