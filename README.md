# Groot - Audio Recorder App

Groot is a Flutter-based audio recording application that allows users to record, play, delete, and share audio files. It features a dark/light theme toggle and stores recordings locally using SQLite.

## Features
✅ **Audio Recording** - Start and stop recording with a simple button.
✅ **Waveform Visualization** - Displays real-time waveform while recording.
✅ **Playback & Management** - Play, delete, and share recorded audio files.
✅ **SQLite Storage** - Saves recordings with metadata (duration, timestamp, waveform data).
✅ **Dark/Light Mode** - Toggle between dark and light themes.

## Project Structure
```
groot/
│── lib/
│   │── main.dart                 # Entry point of the app
│   │── controllers/
│   │   │── theme_controller.dart  # Controls dark/light theme switching
│   │   └── recording_controller.dart # Handles audio recording logic
│   │── pages/
│   │   │── main_page.dart         # Home page with recordings list
│   │   └── recording_page.dart    # Recording interface
│   │── utils/
│   │   └── database_helper.dart   # Manages local SQLite database
│   └── widgets/
│       └── custom_widgets.dart    # Any reusable widgets (optional)
│── android/                       # Android-specific files
│── ios/                           # iOS-specific files
│── pubspec.yaml                   # Dependencies and project config
│── README.md                      # Project documentation
```

## Installation
1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/groot.git
   cd groot
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Dependencies
- `flutter_sound` - Audio recording functionality.
- `audio_waveforms` - Waveform visualization.
- `get` - State management.
- `path_provider` - File storage management.
- `permission_handler` - Handles microphone permissions.
- `share_plus` - Allows users to share recordings.
- `sqflite` - Local SQLite database for storing recordings.

## Contributing
Feel free to contribute! Fork the repository, make changes, and submit a pull request.

## License
This project is licensed under the MIT License.

---
Developed with ❤️ using Flutter.

