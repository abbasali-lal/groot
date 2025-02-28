// recording_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import '../controller/recording_controller.dart';

class RecordingPage extends StatelessWidget {
  final RecordingController controller = Get.put(RecordingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Recorder'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
              controller.formattedTime.value,
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            )),
            SizedBox(height: 20),
            AudioWaveforms(
              enableGesture: false,
              size: Size(MediaQuery.of(context).size.width, 120),
              recorderController: controller.recorderController,
            ),
            SizedBox(height: 30),
            Obx(() => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(controller.isRecording.value ? 30 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: controller.isRecording.value
                    ? [BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)]
                    : [],
              ),
              child: Icon(
                Icons.mic,
                size: 100,
                color: controller.isRecording.value ? Colors.redAccent : Colors.blueAccent,
              ),
            )),
            SizedBox(height: 30),
            Obx(() => GestureDetector(
              onTap: controller.isRecording.value ? controller.stopRecording : controller.startRecording,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  color: controller.isRecording.value ? Colors.redAccent : Colors.blueAccent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: controller.isRecording.value ? Colors.redAccent.withOpacity(0.5) : Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(controller.isRecording.value ? Icons.stop : Icons.mic, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      controller.isRecording.value ? 'Stop Recording' : 'Start Recording',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
