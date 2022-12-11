import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:live_location/layout/app_map.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';


class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(
    enable
    :
    true
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              TextButton(
                  onPressed: () {
                    _getLocation();
                  }, child: const Text("Add my Location")),
              TextButton(
                  onPressed: () {
                    _listenLocation();
                  }, child: const Text("Enable Live Location")),
              TextButton(
                  onPressed: () {
                    _stopListening();
                  }, child: const Text("Stop Live Location")),
              Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('location')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                                title: Text(
                                    snapshot.data!.docs[index]['name']
                                        .toString()),
                                trailing: IconButton(
                                  icon: const Icon(Icons.directions),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) =>
                                            AppMapScreen(
                                                snapshot.data!.docs[index]
                                                    .id)));
                                  },
                                ),
                                subtitle: Row(children: [
                                  Text(snapshot.data!.docs[index]['latitude']
                                      .toString()),
                                  Text(snapshot.data!.docs[index]['longitude']
                                      .toString())
                                ]));
                          });
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }

  _getLocation() async {
    try {
      final loc.LocationData locationData = await location.getLocation();
      await FirebaseFirestore.instance.collection('location').doc('user1').set({
        'latitude': locationData.latitude,
        'longitude': locationData.longitude
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance.collection('location').doc('user1').set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'name': 'john'
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
