import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/audio_player_provider.dart';

class AudioSettingsWidget extends StatefulWidget {
  const AudioSettingsWidget({super.key});

  @override
  State<AudioSettingsWidget> createState() => _AudioSettingsWidgetState();
}

class _AudioSettingsWidgetState extends State<AudioSettingsWidget> {
  Duration? _sleepTimerDuration;
  Timer? _sleepTimer;
  bool _autoPauseOnDisconnect = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoPauseOnDisconnect = prefs.getBool('auto_pause_disconnect') ?? true;
    });
  }

  Future<void> _saveAutoPauseSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_pause_disconnect', value);
  }

  String get _sleepTimerSubtitle {
    if (_sleepTimerDuration == null) {
      return 'Off';
    } else {
      return 'Will pause in ${_sleepTimerDuration!.inMinutes} minutes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        final theme = Theme.of(context);

        return GlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Volume Control
              GlassContainer(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.2 * 255).toInt()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Volume',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(audioProvider.volume * 100).round()}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withAlpha((0.3 * 255).toInt()),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withAlpha((0.2 * 255).toInt()),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: audioProvider.volume,
                        onChanged: (value) => audioProvider.setVolume(value),
                        min: 0.0,
                        max: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDivider(),
              
              // Playback Speed
              GlassMusicCard(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.speed, color: Colors.white),
                ),
                title: 'Playback Speed',
                subtitle: '${audioProvider.speed.toStringAsFixed(1)}x',
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: () => _showSpeedDialog(context, audioProvider),
                height: 70,
                padding: const EdgeInsets.all(16),
              ),
              _buildDivider(),
              
              // Equalizer (placeholder)
              GlassMusicCard(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.equalizer, color: Colors.white),
                ),
                title: 'Equalizer',
                subtitle: 'Customize audio settings',
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: () => _showEqualizerDialog(context),
                height: 70,
                padding: const EdgeInsets.all(16),
              ),
              _buildDivider(),
              
              // Auto-pause on headphone disconnect
              GlassContainer(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.2 * 255).toInt()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.headset, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-pause on headphone disconnect',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Automatically pause when headphones are removed',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withAlpha((0.7 * 255).toInt()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _autoPauseOnDisconnect,
                      onChanged: (value) {
                        setState(() {
                          _autoPauseOnDisconnect = value;
                        });
                        _saveAutoPauseSetting(value);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.white.withAlpha((0.3 * 255).toInt()),
                      inactiveThumbColor: Colors.white.withAlpha((0.5 * 255).toInt()),
                      inactiveTrackColor: Colors.white.withAlpha((0.2 * 255).toInt()),
                    ),
                  ],
                ),
              ),
              _buildDivider(),
              
              // Sleep Timer
              GlassMusicCard(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.timer, color: Colors.white),
                ),
                title: 'Sleep Timer',
                subtitle: _sleepTimerSubtitle,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: () => _showSleepTimerDialog(context, audioProvider),
                height: 70,
                padding: const EdgeInsets.all(16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withAlpha((0.1 * 255).toInt()),
    );
  }

  void _showSpeedDialog(BuildContext context, AudioPlayerProvider audioProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Playback Speed',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${audioProvider.speed.toStringAsFixed(1)}x',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withAlpha((0.3 * 255).toInt()),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withAlpha((0.2 * 255).toInt()),
                    ),
                    child: Slider(
                      value: audioProvider.speed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 6,
                      onChanged: (value) {
                        audioProvider.setSpeed(value);
                        setState(() {}); // Update dialog UI
                      },
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0.5x', style: TextStyle(color: Colors.white70)),
                      Text('2.0x', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GlassButton(
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context, AudioPlayerProvider audioProvider) {
    Duration? selectedDuration = _sleepTimerDuration;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set Sleep Timer',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButton<Duration?>(
                      value: selectedDuration,
                      dropdownColor: Colors.black87,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<Duration?>(
                          value: null,
                          child: Text('Off', style: TextStyle(color: Colors.white)),
                        ),
                        ...[ 5, 10, 15, 20, 30, 45, 60, 90, 120].map((minutes) {
                          final duration = Duration(minutes: minutes);
                          return DropdownMenuItem<Duration?>(
                            value: duration,
                            child: Text(
                              minutes < 60
                                  ? '$minutes minutes'
                                  : '${(minutes / 60).toStringAsFixed(minutes % 60 == 0 ? 0 : 1)} hour${minutes > 60 ? 's' : ''}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => selectedDuration = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassButton(
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    GlassButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _setSleepTimer(selectedDuration, audioProvider);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: const Text('Set', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setSleepTimer(Duration? duration, AudioPlayerProvider audioProvider) {
    _sleepTimer?.cancel();
    setState(() {
      _sleepTimerDuration = duration;
    });
    if (duration != null) {
      _sleepTimer = Timer(duration, () {
        audioProvider.pause();
        setState(() {
          _sleepTimerDuration = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sleep timer ended - Music paused'),
            backgroundColor: Colors.black.withAlpha((0.8 * 255).toInt()),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  void _showEqualizerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Equalizer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Equalizer feature coming soon!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GlassButton(
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}