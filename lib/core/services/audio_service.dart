// import 'package:audio_service/audio_service.dart'; // Remove duplicate import if present
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/models/song.dart';

class AudioPlayerService extends BaseAudioHandler {

  // Play a queue of DownloadedSong MediaItems
  Future<void> setDownloadedQueue(List<MediaItem> items, {int initialIndex = 0}) async {
    _queue = items.map((item) => Song(
      id: int.tryParse(item.id) ?? 0,
      title: item.title,
      artist: item.artist ?? '',
      album: '',
      albumArt: item.artUri?.toString(),
      path: item.extras?['filePath'] ?? '',
      duration: item.duration?.inMilliseconds ?? 0,
      genre: null,
      year: null,
      track: null,
      size: 0, // Provide default int value
      dateAdded: null,
      dateModified: null,
      isFavorite: false,
      playCount: 0,
      lastPlayed: null,
    )).toList();
    _currentIndex = initialIndex;
    await _audioPlayer.setAudioSources(
      items.map((item) => AudioSource.uri(Uri.file(item.extras?['filePath'] ?? ''))).toList(),
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );
    if (items.isNotEmpty) {
      mediaItem.add(items[initialIndex]);
    }
  }

  /// Play a custom audio URL (e.g., from YouTube Music)
  Future<void> playCustomUrl(String url, {String? title, String? artist, String? artUri}) async {
    // Stop current playback
    await _audioPlayer.stop();
    // Set the new source
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
    // Set a temporary media item for notification/lockscreen
    mediaItem.add(MediaItem(
      id: url,
      title: title ?? 'YouTube Music',
      artist: artist ?? '',
      artUri: artUri != null ? Uri.parse(artUri) : null,
    ));
    // Play
    await _audioPlayer.play();
  }
  final _audioPlayer = AudioPlayer();
  // Removed deprecated ConcatenatingAudioSource

  List<Song> _queue = [];
  int _currentIndex = 0;
  LoopMode _loopMode = LoopMode.off;
  bool _shuffleMode = false;

  AudioPlayerService() {
    _init();
  }

  void _init() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playerState.playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[playerState.processingState]!,
          playing: playerState.playing,
        ),
      );
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });

    // Listen to current index changes
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < _queue.length) {
        _currentIndex = index;
        mediaItem.add(_createMediaItem(_queue[index]));
      }
    });

    // Set initial state
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.idle,
      ),
    );
  }

  MediaItem _createMediaItem(Song song) {
    return MediaItem(
      id: song.id.toString(),
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: Duration(milliseconds: song.duration),
      artUri: song.albumArt != null ? Uri.file(song.albumArt!) : null,
    );
  }

  Future<void> setQueue(List<Song> songs, {int initialIndex = 0}) async {
    _queue = songs;
    _currentIndex = initialIndex;

    await _audioPlayer.setAudioSources(
      songs.map((song) => AudioSource.uri(Uri.file(song.path))).toList(),
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );

    if (songs.isNotEmpty) {
      mediaItem.add(_createMediaItem(songs[initialIndex]));
    }
  }

  Future<void> addToQueue(Song song) async {
  _queue.add(song);
  // No direct add for setAudioSources, would need to reset sources if needed
  }

  Future<void> removeFromQueue(int index) async {
    if (index < _queue.length) {
      _queue.removeAt(index);
      // No direct remove for setAudioSources, would need to reset sources if needed
    }
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> stop() => _audioPlayer.stop();

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> skipToNext() => _audioPlayer.seekToNext();

  @override
  Future<void> skipToPrevious() => _audioPlayer.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _queue.length) {
      await _audioPlayer.seek(Duration.zero, index: index);
    }
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    _loopMode = loopMode;
    await _audioPlayer.setLoopMode(loopMode);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode mode) async {
  _shuffleMode = mode == AudioServiceShuffleMode.all;
  await _audioPlayer.setShuffleModeEnabled(_shuffleMode);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // Getters - Fixed the syntax
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;

  // Renamed to avoid conflict with BaseAudioHandler.queue
  List<Song> get songQueue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Song? get currentSong => _queue.isNotEmpty && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;
  LoopMode get loopMode => _loopMode;
  bool get shuffleMode => _shuffleMode;

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await super.onTaskRemoved();
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'setLoopMode':
        final mode = LoopMode.values[extras!['mode'] as int];
        await setLoopMode(mode);
        break;
      case 'setShuffleMode':
        final enabled = extras!['enabled'] as bool;
        await setShuffleMode(
          enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        );
        break;
      case 'setSpeed':
        await setSpeed(extras!['speed'] as double);
        break;
      case 'setVolume':
        await setVolume(extras!['volume'] as double);
        break;
    }
  }

  @override
  Future<void> onNotificationDeleted() async {
    await stop();
  }
}
