import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/presentation/providers/offline_library_provider.dart';
import 'package:music_app/data/models/downloaded_song.dart';
import 'package:music_app/presentation/providers/audio_player_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/widgets/mini_player.dart';

class OfflineLibraryScreen extends StatefulWidget {
  const OfflineLibraryScreen({super.key});

  @override
  State<OfflineLibraryScreen> createState() => _OfflineLibraryScreenState();
}

class _OfflineLibraryScreenState extends State<OfflineLibraryScreen> {
  LoopMode _loopMode = LoopMode.off;
  String? _fileError;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  String _sortBy = 'date';
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    // ✅ Defer provider call until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OfflineLibraryProvider>(context, listen: false).loadDownloadedSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OfflineLibraryProvider, AudioPlayerProvider>(
      builder: (context, provider, audioProvider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.downloadedSongs.isEmpty) {
          return const Center(child: Text('No downloaded songs.'));
        }

        // Sorting
        List<DownloadedSong> sortedSongs = List.from(provider.downloadedSongs);
        if (_sortBy == 'title') {
          sortedSongs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        } else if (_sortBy == 'author') {
          sortedSongs.sort((a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
        } else {
          sortedSongs.sort((a, b) => a.downloadedAt.compareTo(b.downloadedAt));
        }
        if (!_ascending) sortedSongs = sortedSongs.reversed.toList();

        // Helper for repeat icon
        IconData repeatIcon;
        switch (_loopMode) {
          case LoopMode.one:
            repeatIcon = Icons.repeat_one;
            break;
          case LoopMode.all:
            repeatIcon = Icons.repeat;
            break;
          default:
            repeatIcon = Icons.repeat;
        }

        return Stack(
          children: [
            if (_fileError != null)
              Container(
                color: Colors.red.withOpacity(0.8),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_fileError!, style: const TextStyle(color: Colors.white))),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _fileError = null),
                    ),
                  ],
                ),
              ),
            Column(
              children: [
                // Sorting/filtering bar + playback controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Text('Sort by:'),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _sortBy,
                        items: const [
                          DropdownMenuItem(value: 'date', child: Text('Date Downloaded')),
                          DropdownMenuItem(value: 'title', child: Text('Title')),
                          DropdownMenuItem(value: 'author', child: Text('Artist')),
                        ],
                        onChanged: (val) => setState(() => _sortBy = val ?? 'date'),
                      ),
                      IconButton(
                        icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
                        onPressed: () => setState(() => _ascending = !_ascending),
                      ),
                      // Playback controls
                      IconButton(
                        icon: Icon(audioProvider.shuffleMode ? Icons.shuffle_on : Icons.shuffle),
                        tooltip: 'Shuffle',
                        onPressed: () async {
                          await audioProvider.toggleShuffleDownloaded();
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(repeatIcon),
                        tooltip: 'Repeat',
                        onPressed: () async {
                          setState(() {
                            if (_loopMode == LoopMode.off) {
                              _loopMode = LoopMode.all;
                            } else if (_loopMode == LoopMode.all) {
                              _loopMode = LoopMode.one;
                            } else {
                              _loopMode = LoopMode.off;
                            }
                          });
                          await audioProvider.setDownloadedLoopMode(_loopMode);
                        },
                      ),
                      const Spacer(),
                      if (_selectionMode)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete Selected',
                          onPressed: _selectedIds.isEmpty
                              ? null
                              : () async {
                                  for (final id in _selectedIds) {
                                    await provider.deleteDownloadedSong(id);
                                  }
                                  setState(() {
                                    _selectedIds.clear();
                                    _selectionMode = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Selected songs deleted.')),
                                  );
                                },
                        ),
                      IconButton(
                        icon: Icon(_selectionMode ? Icons.close : Icons.select_all),
                        tooltip: _selectionMode ? 'Cancel Selection' : 'Select',
                        onPressed: () {
                          setState(() {
                            if (_selectionMode) {
                              _selectionMode = false;
                              _selectedIds.clear();
                            } else {
                              _selectionMode = true;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: sortedSongs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final song = sortedSongs[index];
                      final selected = _selectedIds.contains(song.id);
                      return ListTile(
                        leading: song.thumbnailUrl.isNotEmpty
                            ? Image.network(song.thumbnailUrl, width: 56, height: 56, fit: BoxFit.cover)
                            : const Icon(Icons.music_note),
                        title: Text(song.title),
                        subtitle: Text(song.author),
                        trailing: !_selectionMode
                            ? IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await provider.deleteDownloadedSong(song.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Song deleted.')),
                                  );
                                },
                              )
                            : Checkbox(
                                value: selected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedIds.add(song.id);
                                    } else {
                                      _selectedIds.remove(song.id);
                                    }
                                  });
                                },
                              ),
                        onTap: () async {
                          if (_selectionMode) {
                            setState(() {
                              if (selected) {
                                _selectedIds.remove(song.id);
                              } else {
                                _selectedIds.add(song.id);
                              }
                            });
                          } else {
                            final file = File(song.filePath);
                            if (!await file.exists()) {
                              setState(() {
                                _fileError = 'File not found for "${song.title}". You can clean up missing files.';
                              });
                              return;
                            }
                            await audioProvider.playDownloadedQueue(sortedSongs, startIndex: index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Playing offline: ${song.title}')),
                            );
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            _selectionMode = true;
                            _selectedIds.add(song.id);
                          });
                        },
                        selected: selected,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cleaning_services),
                      label: const Text('Remove Missing Files'),
                      onPressed: () async {
                        final provider = Provider.of<OfflineLibraryProvider>(context, listen: false);
                        final removed = await provider.cleanupMissingFiles();
                        setState(() {
                          _fileError = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Removed $removed missing files.')),
                        );
                      },
                    ),
                  ),
                ),
                const MiniPlayer(),
              ],
            ),
            if (provider.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }
}
