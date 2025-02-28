// pages/main_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import '../controller/recording_controller.dart';
import '../controller/theme_controller.dart';
import 'recording_page.dart';

class MainPage extends StatelessWidget {
  final ThemeController _themeController = Get.put(ThemeController());
  final RecordingController _recordingController = Get.put(RecordingController());
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  @override
  Widget build(BuildContext context) {
    _player.openPlayer();

    return Scaffold(
      appBar: AppBar(
        title: Text('Recordings'),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              _themeController.isDarkMode.value
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: _themeController.isDarkMode.value
                  ? Colors.yellow
                  : Colors.blue,
            ),
            onPressed: () {
              _themeController.toggleTheme();
            },
          )),
        ],
      ),
      body: Obx(() => _recordingController.recordings.isEmpty
          ? Center(child: Text('No recordings found'))
          : ListView.builder(
        itemCount: _recordingController.recordings.length,
        itemBuilder: (context, index) {
          return Obx(() {
            bool isExpanded = _recordingController.expandedIndex.value == index;
            bool isPlaying = _recordingController.playingIndex.value == index;

            return Card(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    subtitle: Text(
                      _recordingController.recordings[index]['timestamp'] ?? 'Unknown date',
                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                    ),
                    leading: GestureDetector(
                      onTap: () => _togglePlayPause(index),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text('Recording ${index + 1}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text(_recordingController.recordings[index]['duration'] ?? "00:00")
                      ],
                    ),
                    onTap: () {
                      _recordingController.toggleExpandedIndex(index);
                    },
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _recordingController.deleteRecording(
                                    _recordingController.recordings[index]['id'],
                                    _recordingController.recordings[index]['path']),
                              ),
                              IconButton(
                                icon: Icon(Icons.share, color: Colors.green),
                                onPressed: () => _recordingController.shareRecording(
                                    _recordingController.recordings[index]['path']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          });
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecordingPage()),
          );
          if (result == true) {
            _recordingController.loadRecordings();
          }
        },
        child: Icon(Icons.mic),
      ),
    );
  }

  Future<void> _togglePlayPause(int index) async {
    String path = _recordingController.recordings[index]['path'];
    if (_recordingController.playingIndex.value == index) {
      await _player.stopPlayer();
      _recordingController.playingIndex.value = -1;
    } else {
      await _player.startPlayer(
        fromURI: path,
        whenFinished: () => _recordingController.playingIndex.value = -1,
      );
      _recordingController.playingIndex.value = index;
    }
  }
}