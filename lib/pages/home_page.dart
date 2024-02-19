import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rtx_alert_app/pages/camera/camera_handler.dart';
import 'package:rtx_alert_app/pages/greeting_page/greeting_page.dart';
import 'package:rtx_alert_app/services/location.dart';
import 'package:camera/camera.dart';
import 'package:rtx_alert_app/pages/camera/preview.dart';
import 'package:rtx_alert_app/pages/settings_page.dart';
import 'package:rtx_alert_app/services/auth.dart';
import 'package:rtx_alert_app/pages/fullscreen_map.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  File? selectedImage;
  LocationHandler location = LocationHandler();
  String locationError = '';
  late final CameraActionController cameraActionController = CameraActionController();
  CameraController? homePageCameraController;
  final FirebaseAuthService auth = FirebaseAuthService();
  static bool _locationInitialized = false;

  @override
  void initState() {
    super.initState();
    loadCameras();

    if (!_locationInitialized) {
      initializeLocation();                     //get current location once per session
    }
      //get current location
    cameraActionController.pickExistingPhoto = pickExistingPhoto;
    cameraActionController.takePhotoWithCamera = (camController) => takePhoto(camController);
  }

  List<CameraDescription>? cameras;
  
  Future<void> loadCameras() async {
  try {
    List<CameraDescription> loadedCameras = await availableCameras();
    setState(() {
      cameras = loadedCameras;
    });
  } catch (e) {
    debugPrint(e.toString());
  }
}

  Future<void> pickExistingPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File selectedImageFile = File(image.path);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewPage(previewImage: selectedImageFile),
        ),
      );
    }
  }

  Future<void> takePhoto(CameraController camController) async {
    final XFile image = await camController.takePicture();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PreviewPage(previewImage: File(image.path)),
      ),
    );
  }



  Future<void> initializeLocation() async {
    if (_locationInitialized) return;           //check if initialization has already occurred

    try {
      await location.getCurrentLocation();
      setState(() {
        
      });
    }
    catch (e){
      setState(() {
        locationError = e.toString();
      });
    } finally {
      _locationInitialized = true;              //Mark as initalized regardless of outcome
    }
  }
  

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500, // Set height
          color: Colors.transparent, // Set background color
          child: Column(
            children: [
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Menu Item 1',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  // Handle tap
                  Navigator.pop(context);
                },
              ),
              const Divider(color: Colors.black26), // Divider between ListTiles
              ListTile(
                title: const Text('Menu Item 2',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  // Handle tap
                  Navigator.pop(context);
                },
              ),
              const Divider(color: Colors.black26), // Divider between ListTiles
              ListTile(
                title: const Text('Settings',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  // Handle tap
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                },
              ),
              const Divider(color: Colors.black26), // Divider between ListTiles
              ListTile(
                title: const Text('Sign Out',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  auth.signOut();
                  if (!context.mounted) return;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GreetingPage()));
                },
              ),
              const Divider(color: Colors.black26), // Divider between ListTiles

              // Add more items if needed
            ],
          ),
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  if (cameras == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  CameraHandler camera = CameraHandler(
    cameras: cameras!,
    onControllerCreated: (controller) {
      homePageCameraController = controller;
      cameraActionController.setCameraController(controller);
    },
  );

return Scaffold(
    body: Stack(
      children: [
        if (cameras != null)
          camera,
        FutureBuilder<Position>(
          future: location.getCurrentLocation(), // Fetch the current location
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show loading indicator
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // Show error message
            } else if (snapshot.hasData) {
              // Once data is fetched, update the location display along with the map
              final position = snapshot.data!;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FullScreenMapPage(center: LatLng(position.latitude, position.longitude)),
                  ));
                },
                child: ClipOval(
                  child: Container(
                    width: 100,  // Adjust size as needed
                    height: 100, // Adjust size as needed
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(position.latitude, position.longitude),
                        initialZoom: 13.0,
                        interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                        )
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 50.0,
                              height: 50.0,
                              point: LatLng(position.latitude, position.longitude),
                              child: const Icon(Icons.location_on, size: 35.0, color: Colors.red,),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Text('No location data');
            }
          },
        ),
        // Correctly positioned container on the top right for location info
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black54, // Background color
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: FutureBuilder<Position>(
              future: location.getCurrentLocation(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'LAT: ${snapshot.data!.latitude.toStringAsFixed(2)}, \n'
                    'LON: ${snapshot.data!.longitude.toStringAsFixed(2)}, \n'
                    'ALT: ${snapshot.data!.altitude.toStringAsFixed(2)} meters',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return const Text(
                    'Fetching location...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
          ),
        ),
        
        //button for camera to take a picture
        GestureDetector(
          onTap: () {
            cameraActionController.takePhotoWithCamera!(homePageCameraController!);
          },
          child: button(Icons.camera_alt_outlined, Alignment.bottomCenter),
        ),
        Positioned(
          left: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: () => _showBottomSheet(context),
            backgroundColor: Colors.white,
            child: const Icon(Icons.menu),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: () => cameraActionController.selectExistingPhoto(),
            backgroundColor: Colors.white,
            child: const Icon(Icons.photo_album),
          ),
        ),
      ],
    ),
  );
}
  


  Widget button(IconData icon, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(
          left: 20,
          bottom: 20,
        ),
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [ 
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.black54,
          ),)
      )
    );
  }
}