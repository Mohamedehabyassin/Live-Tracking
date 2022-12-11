import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:live_location/model/location_model.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'dart:ui' as ui;

class DriverCarScreen extends StatefulWidget {
  const DriverCarScreen(this.pickUpLocation, this.pickOffLocation, {super.key});

  final LocationModel? pickUpLocation;
  final LocationModel? pickOffLocation;

  @override
  State<DriverCarScreen> createState() => _DriverCarScreenState();
}

class _DriverCarScreenState extends State<DriverCarScreen> {
  final Completer<GoogleMapController?> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Location location = Location();
  Marker? sourcePosition, destinationPosition;

  // loc.LocationData? _currentPosition;
  LatLng driverLocation = LatLng(30.1614, 31.4709);
  StreamSubscription<loc.LocationData>? locationSubscription;
  LatLng? destLocation = LatLng(0, 0);

  bool driveComing = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNavigation();
    setCustomMapPin();
  }

  BitmapDescriptor? pinLocationIcon;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Marker? markerCar;

  void setCustomMapPin() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/car.png', 80);
    pinLocationIcon = await BitmapDescriptor.fromBytes(markerIcon);

    markerCar = Marker(
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: driverLocation,
        markerId: MarkerId("idCar"));

    setState(() {
      sourcePosition = markerCar;
      destinationPosition = Marker(
        markerId: MarkerId('destination'),
        position:
            LatLng(widget.pickOffLocation!.lat!, widget.pickOffLocation!.lng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      );
    });
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            polylines: Set<Polyline>.of(polylines.values),
            initialCameraPosition: CameraPosition(
              target: driverLocation,
              zoom: 16,
            ),
            markers: {sourcePosition!, destinationPosition!},
            onTap: (latLng) {
              print(latLng);
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        driveComing
                            ? Text(
                                "Driver is Coming ..",
                                style: TextStyle(
                                  color: Color(0xff113660),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : SizedBox(),
                        driveComing
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox(),
                        driveComing
                            ? Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor:
                                        Color(0xff113660).withOpacity(0.7),
                                    backgroundImage: const NetworkImage(
                                        "https://www.shutterstock.com/image-photo/young-handsome-man-beard-wearing-260nw-1768126784.jpg"),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Khaled Maher",
                                        style: TextStyle(
                                          color: Color(0xff113660),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                              primary: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              )),
                                          onPressed: () {},
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: const [
                                              Text(
                                                "Call Now",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Icon(
                                                Icons.call,
                                                color: Colors.green,
                                              )
                                            ],
                                          ))
                                    ],
                                  ))
                                ],
                              )
                            : const Text(
                                "Trip Details",
                                style: TextStyle(
                                  color: Color(0xff113660),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.social_distance,
                                    color: Color(0xff113660),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Distance",
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color: Color(0xff113660),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Time",
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: driveComing
                                    ? Colors.red
                                    : const Color(0xff113660),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            onPressed: () {},
                            child: Text(
                                driveComing ? "Cancel Trip" : "Request Driver"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      )),
    );
  }

  getNavigation() async {
    setState(() {
      getDirections(
          LatLng(widget.pickUpLocation!.lat!, widget.pickUpLocation!.lng!));
    });
  }

  getDirections(LatLng dst) async {
    List<LatLng> polylineCoordinates = [];
    List<dynamic> points = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyBXqpAWyD9AcIWx-VtqljKOLEY5dXMxXNI',
        PointLatLng(driverLocation.latitude, driverLocation.longitude),
        PointLatLng(widget.pickUpLocation!.lat!, widget.pickUpLocation!.lng!),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        points.add({'lat': point.latitude, 'lng': point.longitude});
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    setState(() {});
  }
}
