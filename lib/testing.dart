// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
//
// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/public/flutter_sound_player.dart';
// import 'package:flutter_sound/public/flutter_sound_recorder.dart';
// import 'package:get/get.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sqflite/sqflite.dart';
//
// void main() {
//   runApp(AudioRecorderApp());
// }
//
// class AudioRecorderApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light(),
//       darkTheme: ThemeData.dark(),
//       themeMode: ThemeMode.system,
//       home: MainPage(),
//     );
//   }
// }
//
// class ThemeController extends GetxController {
//   var isDarkMode = false.obs;
//
//   void toggleTheme() {
//     isDarkMode.value = !isDarkMode.value;
//     Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
//   }
// }
//
// class MainPage extends StatelessWidget {
//   final ThemeController _themeController = Get.put(ThemeController());
//   final RecordingController _recordingController = Get.put(RecordingController());
//   final FlutterSoundPlayer _player = FlutterSoundPlayer();
//
//   @override
//   Widget build(BuildContext context) {
//     // Initialize the player when the widget is built
//     _player.openPlayer();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Recordings'),
//         centerTitle: true,
//         actions: [
//           Obx(() => IconButton(
//             icon: Icon(
//               _themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
//               color: _themeController.isDarkMode.value ? Colors.yellow : Colors.blue,
//             ),
//             onPressed: () {
//               _themeController.toggleTheme();
//             },
//           )),
//         ],
//       ),
//       body: Obx(() => _recordingController.recordings.isEmpty
//           ? Center(child: Text('No recordings found'))
//           : ListView.builder(
//         itemCount: _recordingController.recordings.length,
//         itemBuilder: (context, index) {
//           return Obx(() {
//             bool isExpanded = _recordingController.expandedIndex.value == index;
//             bool isPlaying = _recordingController.playingIndex.value == index;
//
//             return Card(
//               margin: EdgeInsets.all(10),
//               child: Column(
//                 children: [
//                   ListTile(
//                     subtitle: Text(
//                       _recordingController.recordings[index]['timestamp'] ?? 'Unknown date',
//                       style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
//                     ),
//                     leading: GestureDetector(
//                       onTap: () => _togglePlayPause(index),
//                       child: Container(
//                         height: 40,
//                         width: 40,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade400,
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                         child: Icon(
//                           isPlaying ? Icons.pause : Icons.play_arrow,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                     title: Row(
//                       children: [
//                         Text('Recording ${index + 1}',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold)),
//                         Spacer(),
//                         Text(_recordingController.recordings[index]['duration'] ?? "00:00")
//                       ],
//                     ),
//                     onTap: () {
//                       _recordingController.toggleExpandedIndex(index);
//                     },
//                   ),
//                   if (isExpanded)
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () => _recordingController.deleteRecording(
//                                     _recordingController.recordings[index]['id'],
//                                     _recordingController.recordings[index]['path']),
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.share, color: Colors.green),
//                                 onPressed: () => _recordingController.shareRecording(
//                                     _recordingController.recordings[index]['path']),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           });
//         },
//       )),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => RecordingPage()),
//           );
//           if (result == true) {
//             _recordingController.loadRecordings();
//           }
//         },
//         child: Icon(Icons.mic),
//       ),
//     );
//   }
//
//   Future<void> _togglePlayPause(int index) async {
//     String path = _recordingController.recordings[index]['path'];
//     if (_recordingController.playingIndex.value == index) {
//       await _player.stopPlayer();
//       _recordingController.playingIndex.value = -1;
//     } else {
//       await _player.startPlayer(
//         fromURI: path,
//         whenFinished: () => _recordingController.playingIndex.value = -1,
//       );
//       _recordingController.playingIndex.value = index;
//     }
//   }
// }
//
// class RecordingController extends GetxController {
//   FlutterSoundRecorder? _recorder;
//   var isRecording = false.obs;
//   String? filePath;
//   Stopwatch stopwatch = Stopwatch();
//   late Timer timer;
//   var formattedTime = "00:00".obs;
//   RecorderController recorderController = RecorderController();
//   var recordings = <Map<String, dynamic>>[].obs;
//
//   // Add these two observables for expanded and playing indices
//   var expandedIndex = RxInt(-1); // Tracks the expanded recording index
//   var playingIndex = RxInt(-1); // Tracks the currently playing recording index
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initRecorder();
//     loadRecordings();
//   }
//
//   Future<void> _initRecorder() async {
//     _recorder = FlutterSoundRecorder();
//     await _recorder!.openRecorder();
//     await Permission.microphone.request();
//     await Permission.storage.request();
//   }
//
//   Future<void> startRecording() async {
//     Directory directory = await getApplicationDocumentsDirectory();
//     filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
//
//     await _recorder!.startRecorder(toFile: filePath);
//     recorderController.record();
//
//     stopwatch.start();
//     timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       formattedTime.value = _formatDuration(stopwatch.elapsed);
//     });
//
//     isRecording.value = true;
//   }
//
//   Future<void> stopRecording() async {
//     await _recorder!.stopRecorder();
//     recorderController.stop();
//
//     stopwatch.stop();
//     timer.cancel();
//     String duration = formattedTime.value;
//     stopwatch.reset();
//     formattedTime.value = "00:00";
//
//     final waveformData = _generateWaveformData();
//     isRecording.value = false;
//     if (filePath != null) {
//       await _saveRecording(filePath!, duration, waveformData);
//       loadRecordings();
//     }
//   }
//
//   String _formatDuration(Duration duration) {
//     int minutes = duration.inMinutes;
//     int seconds = duration.inSeconds.remainder(60);
//     return '$minutes:${seconds.toString().padLeft(2, '0')}';
//   }
//
//   List<double> _generateWaveformData() {
//     final random = Random();
//     return List.generate(100, (index) => random.nextDouble());
//   }
//
//   Future<void> _saveRecording(String path, String duration, List<double> waveformData) async {
//     final database = await openDatabase(join(await getDatabasesPath(), 'recordings.db'), version: 3);
//     await database.insert('recordings', {
//       'path': path,
//       'duration': duration,
//       'timestamp': DateTime.now().toString(),
//       'waveformData': jsonEncode(waveformData),
//     });
//   }
//
//   Future<void> loadRecordings() async {
//     final database = await openDatabase(join(await getDatabasesPath(), 'recordings.db'), version: 3);
//     final recordings = await database.query('recordings');
//     this.recordings.value = recordings;
//   }
//
//   Future<void> deleteRecording(int id, String path) async {
//     final database = await openDatabase(join(await getDatabasesPath(), 'recordings.db'), version: 3);
//     await database.delete('recordings', where: 'id = ?', whereArgs: [id]);
//     File file = File(path);
//     if (await file.exists()) {
//       await file.delete();
//     }
//     loadRecordings();
//   }
//
//   Future<void> shareRecording(String path) async {
//     XFile file = XFile(path);
//     await Share.shareXFiles([file], text: 'Check out this recording!');
//   }
//
//   // Method to toggle the expanded index
//   void toggleExpandedIndex(int index) {
//     if (expandedIndex.value == index) {
//       expandedIndex.value = -1; // Collapse if already expanded
//     } else {
//       expandedIndex.value = index; // Expand the new index
//     }
//   }
//
//   @override
//   void onClose() {
//     _recorder!.closeRecorder();
//     timer.cancel();
//     recorderController.dispose();
//     super.onClose();
//   }
// }
//
// class RecordingPage extends StatelessWidget {
//   final RecordingController controller = Get.put(RecordingController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Voice Recorder'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Obx(() => Text(
//               controller.formattedTime.value,
//               style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
//             )),
//             SizedBox(height: 20),
//             AudioWaveforms(
//               enableGesture: false,
//               size: Size(MediaQuery.of(context).size.width, 120),
//               recorderController: controller.recorderController,
//             ),
//             SizedBox(height: 30),
//             Obx(() => AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               padding: EdgeInsets.all(controller.isRecording.value ? 30 : 20),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 boxShadow: controller.isRecording.value
//                     ? [BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)]
//                     : [],
//               ),
//               child: Icon(
//                 Icons.mic,
//                 size: 100,
//                 color: controller.isRecording.value ? Colors.redAccent : Colors.blueAccent,
//               ),
//             )),
//             SizedBox(height: 30),
//             Obx(() => GestureDetector(
//               onTap: controller.isRecording.value ? controller.stopRecording : controller.startRecording,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 decoration: BoxDecoration(
//                   color: controller.isRecording.value ? Colors.redAccent : Colors.blueAccent,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: controller.isRecording.value ? Colors.redAccent.withOpacity(0.5) : Colors.blueAccent.withOpacity(0.5),
//                       blurRadius: 10,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(controller.isRecording.value ? Icons.stop : Icons.mic, color: Colors.white),
//                     SizedBox(width: 10),
//                     Text(
//                       controller.isRecording.value ? 'Stop Recording' : 'Start Recording',
//                       style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }