import 'package:music_app/data/models/downloaded_song.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/services/audio_service.dart';
import 'package:music_app/data/models/song.dart';

class AudioPlayerProvider extends ChangeNotifier {

  // Play a queue of DownloadedSong objects
  Future<void> playDownloadedQueue(List<DownloadedSong> songs, {int startIndex = 0}) async {
    final mediaItems = songs.map((s) => s.toMediaItem()).toList();
    await _audioHandler.setDownloadedQueue(mediaItems, initialIndex: startIndex);
    notifyListeners();
    await play();
  }

  // Toggle shuffle for downloaded queue
  Future<void> toggleShuffleDownloaded() async {
    _shuffleMode = !_shuffleMode;
    await _audioHandler.setShuffleMode(
      _shuffleMode ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
    notifyListeners();
  }

  // Set repeat/loop mode for downloaded queue
  Future<void> setDownloadedLoopMode(LoopMode loopMode) async {
    _loopMode = loopMode;
    await _audioHandler.setLoopMode(loopMode);
    notifyListeners();
  }

  /// Play a custom audio URL (e.g., from YouTube Music)
  Future<void> playCustomUrl(String url, {String? title, String? artist, String? artUri}) async {
    await _audioHandler.playCustomUrl(url, title: title, artist: artist, artUri: artUri);
    notifyListeners();
  }
  final AudioPlayerService _audioHandler;

  List<Song> _queue = [];
  int _currentIndex = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlayerState _playerState = PlayerState(false, ProcessingState.idle);
  LoopMode _loopMode = LoopMode.off;
  bool _shuffleMode = false;
  double _volume = 1.0;
  double _speed = 1.0;

  AudioPlayerProvider(this._audioHandler) {
    _init();
  }

  void _init() {
    // Listen to position changes
    _audioHandler.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Listen to duration changes
    _audioHandler.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    // Listen to player state changes
    _audioHandler.playerStateStream.listen((playerState) {
      _playerState = playerState;
      notifyListeners();
    });

    // Listen to current index changes
    _audioHandler.currentIndexStream.listen((index) async {
      final queue = await _audioHandler
          .queue
          .first; // Fixed: Added .first to get Future value
      if (index != null && index < queue.length) {
        _currentIndex = index;
        // Fixed: Convert MediaItem to Song - this needs proper implementation based on your Song model
        _queue = queue
            .map((mediaItem) => Song.fromMediaItem(mediaItem))
            .toList();
        notifyListeners();
      }
    });

    // Sync initial state - Fixed: Handle Future properly
    _initializeState();
  }

  Future<void> _initializeState() async {
    try {
      final queue = await _audioHandler.queue.first;
      _queue = queue.map((mediaItem) => Song.fromMediaItem(mediaItem)).toList();
      _currentIndex = await _audioHandler.currentIndexStream.first ?? 0;
      // Note: These properties might need to be accessed differently based on your AudioPlayerService implementation
      // _loopMode = _audioHandler.loopMode;
      // _shuffleMode = _audioHandler.shuffleMode;
    } catch (e) {
      debugPrint('Error initializing state: $e');
    }
  }

  // Getters
  List<Song> get queue => List.unmodifiable(_queue);
  Song? get currentSong => _queue.isNotEmpty && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;
  int get currentIndex => _currentIndex;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _playerState.playing;
  bool get isLoading => _playerState.processingState == ProcessingState.loading;
  bool get isBuffering =>
      _playerState.processingState == ProcessingState.buffering;
  LoopMode get loopMode => _loopMode;
  bool get shuffleMode => _shuffleMode;
  double get volume => _volume;
  double get speed => _speed;

  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  String get positionText {
    final minutes = _position.inMinutes;
    final seconds = _position.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get durationText {
    final minutes = _duration.inMinutes;
    final seconds = _duration.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Playback controls
  Future<void> play() async {
    await _audioHandler.play();
  }

  Future<void> pause() async {
    await _audioHandler.pause();
  }

  Future<void> stop() async {
    await _audioHandler.stop();
  }

  Future<void> playPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  Future<void> seekToNext() async {
    if (hasNext) {
      await _audioHandler.skipToNext();
    }
  }

  Future<void> seekToPrevious() async {
    if (hasPrevious) {
      await _audioHandler.skipToPrevious();
    }
  }

  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _queue.length) {
      await _audioHandler.skipToQueueItem(index);
    }
  }

  Future<void> playSong(Song song) async {
    await setQueue([song]);
    await play();
  }

  Future<void> playPlaylist(List<Song> songs, {int startIndex = 0}) async {
    await setQueue(songs, initialIndex: startIndex);
    await play();
  }

  // Queue management
  Future<void> setQueue(List<Song> songs, {int initialIndex = 0}) async {
    await _audioHandler.setQueue(songs, initialIndex: initialIndex);
    _queue = List.from(songs);
    _currentIndex = initialIndex.clamp(0, songs.length - 1);
    notifyListeners();
  }

  Future<void> addToQueue(Song song) async {
    await _audioHandler.addToQueue(song);
    _queue.add(song);
    notifyListeners();
  }

  Future<void> removeFromQueue(int index) async {
    if (index >= 0 && index < _queue.length) {
      await _audioHandler.removeFromQueue(index);
      _queue.removeAt(index);

      // Adjust current index if necessary
      if (index < _currentIndex) {
        _currentIndex--;
      } else if (index == _currentIndex && _currentIndex >= _queue.length) {
        _currentIndex = _queue.length - 1;
      }
      notifyListeners();
    }
  }

  // Playback modes
  Future<void> setLoopMode(LoopMode loopMode) async {
    _loopMode = loopMode;
    await _audioHandler.setLoopMode(loopMode);
    notifyListeners();
  }

  Future<void> toggleLoopMode() async {
    switch (_loopMode) {
      case LoopMode.off:
        await setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await setLoopMode(LoopMode.off);
        break;
    }
  }

  Future<void> setShuffleMode(bool enabled) async {
    _shuffleMode = enabled;
    // Fixed: Properly convert bool to AudioServiceShuffleMode
    final shuffleMode = enabled
        ? AudioServiceShuffleMode.all
        : AudioServiceShuffleMode.none;
    await _audioHandler.setShuffleMode(shuffleMode);
    notifyListeners();
  }

  Future<void> toggleShuffleMode() async {
    await setShuffleMode(!_shuffleMode);
  }

  // Audio settings
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioHandler.setVolume(_volume);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.5, 2.0);
    await _audioHandler.setSpeed(_speed);
    notifyListeners();
  }

  // Utility methods
  Future<void> seekForward([
    Duration duration = const Duration(seconds: 10),
  ]) async {
    final newPosition = _position + duration;
    await seek(newPosition > _duration ? _duration : newPosition);
  }

  Future<void> seekBackward([
    Duration duration = const Duration(seconds: 10),
  ]) async {
    final newPosition = _position - duration;
    await seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  String get loopModeText {
    switch (_loopMode) {
      case LoopMode.off:
        return 'Off';
      case LoopMode.all:
        return 'All';
      case LoopMode.one:
        return 'One';
    }
  }

  IconData get loopModeIcon {
    switch (_loopMode) {
      case LoopMode.off:
        return Icons.repeat;
      case LoopMode.all:
        return Icons.repeat;
      case LoopMode.one:
        return Icons.repeat_one;
    }
  }

  @override
  void dispose() {
    // Clean up any subscriptions here if needed
    super.dispose();
  }
}
