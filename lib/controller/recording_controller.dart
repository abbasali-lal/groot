import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import '../utils/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class RecordingController extends GetxController {
  FlutterSoundRecorder? _recorder;
  var isRecording = false.obs;
  String? filePath;
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;
  var formattedTime = "00:00".obs;
  RecorderController recorderController = RecorderController();
  var recordings = <Map<String, dynamic>>[].obs;
  var expandedIndex = RxInt(-1);
  var playingIndex = RxInt(-1);

  @override
  void onInit() {
    super.onInit();
    _initRecorder();
    loadRecordings();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> startRecording() async {
    Directory directory = await getApplicationDocumentsDirectory();
    filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder!.startRecorder(toFile: filePath);
    recorderController.record();

    stopwatch.start();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      formattedTime.value = _formatDuration(stopwatch.elapsed);
    });

    isRecording.value = true;
  }

  Future<void> stopRecording() async {
    await _recorder!.stopRecorder();
    recorderController.stop();

    stopwatch.stop();
    timer.cancel();
    String duration = formattedTime.value;
    stopwatch.reset();
    formattedTime.value = "00:00";

    final waveformData = _generateWaveformData();
    isRecording.value = false;
    if (filePath != null) {
      await _saveRecording(filePath!, duration, waveformData);
      loadRecordings();
    }
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  List<double> _generateWaveformData() {
    final random = Random();
    return List.generate(100, (index) => random.nextDouble());
  }

  Future<void> _saveRecording(String path, String duration, List<double> waveformData) async {
    await DatabaseHelper().insertRecording({
      'path': path,
      'duration': duration,
      'timestamp': DateTime.now().toString(),
      'waveformData': jsonEncode(waveformData),
    });
  }

  Future<void> loadRecordings() async {
    recordings.value = await DatabaseHelper().getRecordings();
  }

  Future<void> deleteRecording(int id, String path) async {
    await DatabaseHelper().deleteRecording(id);
    File file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    loadRecordings();
  }

  Future<void> shareRecording(String path) async {
    XFile file = XFile(path);
    await Share.shareXFiles([file], text: 'Check out this recording!');
  }

  void toggleExpandedIndex(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  @override
  void onClose() {
    _recorder!.closeRecorder();
    timer.cancel();
    recorderController.dispose();
    super.onClose();
  }
}
