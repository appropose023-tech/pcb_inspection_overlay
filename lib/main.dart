import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'live_overlay.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LiveInspector(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LiveInspector extends StatefulWidget {
  const LiveInspector({super.key});

  @override
  State<LiveInspector> createState() => _LiveInspectorState();
}

class _LiveInspectorState extends State<LiveInspector> {
  CameraController? controller;
  InspectionResult? liveResult;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    initCam();
  }

  Future<void> initCam() async {
    controller = CameraController(cameras.first, ResolutionPreset.medium);
    await controller!.initialize();
    if (mounted) setState(() {});
    controller!.startImageStream(processFrame);
  }

  Future<void> processFrame(CameraImage image) async {
    if (sending) return;

    sending = true;

    // Convert YUV → JPEG
    final jpeg = await convertToJpeg(image);
    final temp = File("${Directory.systemTemp.path}/frame.jpg");
    await temp.writeAsBytes(jpeg);

    ApiService api = ApiService();
    final result = await api.inspect(temp);

    if (mounted) {
      setState(() => liveResult = result);
    }

    sending = false;
  }

  // Converts YUV to JPEG
  Future<Uint8List> convertToJpeg(CameraImage img) async {
    final plane = img.planes[0];
    return Uint8List.fromList(plane.bytes); // backend handles decoding
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(controller!),
          if (liveResult != null)
            LiveOverlay(
              defects: liveResult!.defects,
              scaleX: size.width / controller!.value.previewSize!.height,
              scaleY: size.height / controller!.value.previewSize!.width,
            ),
        ],
      ),
    );
  }
}
