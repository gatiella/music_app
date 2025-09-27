class DurationUtils {
  /// Formats duration in milliseconds to MM:SS format
  static String formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    return formatDurationFromDuration(duration);
  }

  /// Formats Duration object to MM:SS or HH:MM:SS format
  static String formatDurationFromDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(1, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(1, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Formats duration for display in different contexts
  static String formatDurationDetailed(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else if (minutes > 0) {
      if (seconds > 0) {
        return '${minutes}m ${seconds}s';
      } else {
        return '${minutes}m';
      }
    } else {
      return '${seconds}s';
    }
  }

  /// Formats total duration for albums or playlists
  static String formatTotalDuration(int totalMilliseconds) {
    final duration = Duration(milliseconds: totalMilliseconds);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Parses duration string (MM:SS or HH:MM:SS) to milliseconds
  static int parseDurationString(String durationString) {
    final parts = durationString.split(':');

    if (parts.length == 2) {
      // MM:SS format
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return (minutes * 60 + seconds) * 1000;
    } else if (parts.length == 3) {
      // HH:MM:SS format
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = int.tryParse(parts[2]) ?? 0;
      return (hours * 3600 + minutes * 60 + seconds) * 1000;
    }

    return 0;
  }

  /// Calculates progress percentage
  static double calculateProgress(int currentPosition, int totalDuration) {
    if (totalDuration <= 0) return 0.0;
    final progress = currentPosition / totalDuration;
    return progress.clamp(0.0, 1.0);
  }

  /// Calculates position from progress percentage
  static int calculatePositionFromProgress(double progress, int totalDuration) {
    final position = (progress * totalDuration).round();
    return position.clamp(0, totalDuration);
  }

  /// Formats remaining time
  static String formatRemainingTime(int currentPosition, int totalDuration) {
    final remaining = totalDuration - currentPosition;
    if (remaining <= 0) return '0:00';
    return formatDuration(remaining);
  }

  /// Checks if duration is valid
  static bool isValidDuration(int milliseconds) {
    return milliseconds > 0 &&
        milliseconds < Duration.millisecondsPerDay * 365; // Less than a year
  }

  /// Formats duration for accessibility
  static String formatDurationForAccessibility(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    String result = '';

    if (hours > 0) {
      result += '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }

    if (minutes > 0) {
      if (result.isNotEmpty) result += ', ';
      result += '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }

    if (seconds > 0 && hours == 0) {
      if (result.isNotEmpty) result += ', ';
      result += '$seconds ${seconds == 1 ? 'second' : 'seconds'}';
    }

    return result.isEmpty ? '0 seconds' : result;
  }

  /// Gets time until target (e.g., for sleep timer)
  static String getTimeUntil(DateTime target) {
    final now = DateTime.now();
    final difference = target.difference(now);

    if (difference.isNegative) return 'Expired';

    return formatDurationFromDuration(difference);
  }

  /// Formats duration in a compact way for UI
  static String formatCompact(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Adds two durations safely
  static int addDurations(int duration1, int duration2) {
    return (duration1 + duration2).clamp(0, Duration.millisecondsPerDay * 365);
  }

  /// Subtracts two durations safely
  static int subtractDurations(int duration1, int duration2) {
    return (duration1 - duration2).clamp(0, duration1);
  }

  /// Gets average duration from a list
  static int getAverageDuration(List<int> durations) {
    if (durations.isEmpty) return 0;
    final total = durations.fold(0, (sum, duration) => sum + duration);
    return total ~/ durations.length;
  }

  /// Gets total duration from a list
  static int getTotalDuration(List<int> durations) {
    return durations.fold(0, (sum, duration) => sum + duration);
  }

  /// Formats duration range (e.g., "2:30 - 4:15")
  static String formatDurationRange(int startMs, int endMs) {
    return '${formatDuration(startMs)} - ${formatDuration(endMs)}';
  }

  /// Gets duration category (short, medium, long)
  static String getDurationCategory(int milliseconds) {
    final minutes = milliseconds / (1000 * 60);

    if (minutes < 2) return 'Very Short';
    if (minutes < 4) return 'Short';
    if (minutes < 6) return 'Medium';
    if (minutes < 10) return 'Long';
    return 'Very Long';
  }

  /// Checks if duration is within a range
  static bool isDurationInRange(int duration, int minMs, int maxMs) {
    return duration >= minMs && duration <= maxMs;
  }
}
