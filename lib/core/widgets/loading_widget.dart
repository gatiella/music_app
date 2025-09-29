import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
import 'package:music_app/app/theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool showMessage;
  final bool useGlass;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 50.0,
    this.color,
    this.showMessage = true,
    this.useGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? MusicAppTheme.primaryPurple;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            strokeWidth: 3,
          ),
        ),
        if (showMessage && message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: useGlass ? Colors.white : null,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (useGlass) {
      return Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      );
    }

    return Center(child: content);
  }
}

class PulsingLoadingWidget extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final bool useGlass;

  const PulsingLoadingWidget({
    super.key,
    this.size = 50.0,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.useGlass = false,
  });

  @override
  State<PulsingLoadingWidget> createState() => _PulsingLoadingWidgetState();
}

class _PulsingLoadingWidgetState extends State<PulsingLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulseColor = widget.color ?? MusicAppTheme.primaryPurple;

    Widget content = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size * (0.8 + _animation.value * 0.4),
          height: widget.size * (0.8 + _animation.value * 0.4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [pulseColor, MusicAppTheme.accentPink],
            ),
            boxShadow: [
              BoxShadow(
                color: pulseColor.withAlpha(((0.4 * _animation.value) * 255).toInt()),
                blurRadius: 20 * _animation.value,
                spreadRadius: 5 * _animation.value,
              ),
            ],
          ),
          child: const Icon(Icons.music_note, color: Colors.white, size: 24),
        );
      },
    );

    if (widget.useGlass) {
      return Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      );
    }

    return Center(child: content);
  }
}

class DotsLoadingWidget extends StatefulWidget {
  final Color? color;
  final double dotSize;
  final Duration duration;
  final bool useGlass;

  const DotsLoadingWidget({
    super.key,
    this.color,
    this.dotSize = 8.0,
    this.duration = const Duration(milliseconds: 600),
    this.useGlass = false,
  });

  @override
  State<DotsLoadingWidget> createState() => _DotsLoadingWidgetState();
}

class _DotsLoadingWidgetState extends State<DotsLoadingWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(duration: widget.duration, vsync: this);
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      MusicAppTheme.primaryPurple,
      MusicAppTheme.primaryBlue,
      MusicAppTheme.accentPink,
    ];

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.dotSize / 4),
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: 0.5 + (_animations[index].value * 0.5),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[index % colors.length].withAlpha(((0.5 + (_animations[index].value * 0.5)) * 255).toInt()),
                    boxShadow: [
                      BoxShadow(
                        color: colors[index % colors.length].withAlpha(((0.3 * _animations[index].value) * 255).toInt()),
                        blurRadius: 8 * _animations[index].value,
                        spreadRadius: 2 * _animations[index].value,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );

    if (widget.useGlass) {
      return Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      );
    }

    return Center(child: content);
  }
}

class SkeletonLoadingWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool useGlass;

  const SkeletonLoadingWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.useGlass = false,
  });

  @override
  State<SkeletonLoadingWidget> createState() => _SkeletonLoadingWidgetState();
}

class _SkeletonLoadingWidgetState extends State<SkeletonLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;
    final isDark = theme.brightness == Brightness.dark;

  final baseColor = isDark
    ? customColors.glassContainer.withAlpha((0.1 * 255).toInt())
    : Colors.grey[300]!;
  final highlightColor = isDark
    ? customColors.glassContainer.withAlpha((0.2 * 255).toInt())
    : Colors.grey[100]!;

    Widget content = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: baseColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  left: widget.width * _animation.value,
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [baseColor, highlightColor, baseColor],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (widget.useGlass) {
      return GlassContainer(
        width: widget.width,
        height: widget.height,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: content,
      );
    }

    return content;
  }
}

class SongItemSkeleton extends StatelessWidget {
  final bool useGlass;

  const SongItemSkeleton({super.key, this.useGlass = false});

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SkeletonLoadingWidget(
            width: 50,
            height: 50,
            borderRadius: 8,
            useGlass: false,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoadingWidget(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                  useGlass: false,
                ),
                const SizedBox(height: 8),
                SkeletonLoadingWidget(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 14,
                  borderRadius: 4,
                  useGlass: false,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SkeletonLoadingWidget(
            width: 40,
            height: 16,
            borderRadius: 4,
            useGlass: false,
          ),
        ],
      ),
    );

    if (useGlass) {
      return GlassContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: content,
      );
    }

    return content;
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;
  final Color? overlayColor;
  final bool useGlass;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
    this.overlayColor,
    this.useGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withAlpha((0.3 * 255).toInt()),
            child: LoadingWidget(
              message: loadingMessage,
              color: Colors.white,
              useGlass: useGlass,
            ),
          ),
      ],
    );
  }
}

class RefreshLoadingWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  final bool isLoading;
  final String? message;
  final bool useGlass;

  const RefreshLoadingWidget({
    super.key,
    required this.onRefresh,
    this.isLoading = false,
    this.message,
    this.useGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          const PulsingLoadingWidget(useGlass: false),
          const SizedBox(height: 16),
          Text(
            'Refreshing...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: useGlass ? Colors.white : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  MusicAppTheme.primaryPurple.withAlpha((0.3 * 255).toInt()),
                  MusicAppTheme.accentPink.withAlpha((0.3 * 255).toInt()),
                ],
              ),
            ),
            child: const Icon(Icons.refresh, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Pull to refresh',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: useGlass
                  ? Colors.white
                  : theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          GlassButton(
            onPressed: onRefresh,
            child: Text(
              'Refresh',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );

    if (useGlass) {
      return Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: content,
        ),
      );
    }

    return Center(child: content);
  }
}
