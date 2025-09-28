import 'package:flutter/material.dart';
import 'package:music_app/app/glassmorphism_widgets.dart';
import 'package:music_app/app/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Widget? bottom;
  final double? bottomHeight;
  final bool useGlass;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.onBackPressed,
    this.showBackButton = false,
    this.bottom,
    this.bottomHeight,
    this.useGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useGlass) {
      return GlassAppBar(
        title: title,
        leading: _buildLeading(context),
        actions: actions,
        centerTitle: centerTitle,
        backgroundColor: backgroundColor,
        elevation: elevation,
      );
    }

    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? theme.appBarTheme.foregroundColor,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation,
      leading: _buildLeading(context),
      actions: actions,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight ?? 48.0),
              child: bottom!,
            )
          : null,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }

    if (showBackButton || Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }

    return null;
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom != null ? (bottomHeight ?? 48.0) : 0),
  );
}

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final List<Color>? gradientColors;
  final Color? foregroundColor;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool useGlass;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.gradientColors,
    this.foregroundColor,
    this.onBackPressed,
    this.showBackButton = false,
    this.useGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? MusicAppTheme.primaryGradient;
    final textColor = foregroundColor ?? Colors.white;

    if (useGlass) {
      return GradientBackground(
        colors: colors,
        child: GlassAppBar(
          title: title,
          leading: _buildLeading(context),
          actions: actions,
          centerTitle: centerTitle,
          backgroundColor: Colors.transparent,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        leading: _buildLeading(context),
        actions: actions,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }

    if (showBackButton || Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }

    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClearPressed;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool useGlass;

  const SearchAppBar({
    super.key,
    this.hintText = 'Search...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClearPressed,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.useGlass = true,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
      widget.onSearchChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useGlass) {
      return GlassAppBar(
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed:
                    widget.onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        title: null, // We'll put the search field in the title space
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GlassTextField(
                controller: _controller,
                hintText: widget.hintText,
                onChanged: widget.onSearchChanged,
                suffixIcon: _hasText
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _controller.clear();
                          widget.onClearPressed?.call();
                        },
                      )
                    : const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
          ...?widget.actions,
        ],
      );
    }

    return AppBar(
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  widget.onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Theme.of(context).hintColor),
        ),
        style: TextStyle(
          color: Theme.of(context).appBarTheme.foregroundColor,
          fontSize: 18,
        ),
        onSubmitted: (_) => widget.onSearchSubmitted?.call(),
      ),
      actions: [
        if (_hasText)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              widget.onClearPressed?.call();
            },
          ),
        ...?widget.actions,
      ],
    );
  }
}

class CollapsibleAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? backgroundImage;
  final List<Widget>? actions;
  final Widget? leading;
  final double expandedHeight;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool pinned;
  final bool floating;
  final Widget? bottom;
  final bool useGlass;
  final List<Color>? gradientColors;

  const CollapsibleAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.backgroundImage,
    this.actions,
    this.leading,
    this.expandedHeight = 200.0,
    this.backgroundColor,
    this.foregroundColor,
    this.pinned = true,
    this.floating = false,
    this.bottom,
    this.useGlass = true,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ?? MusicAppTheme.primaryGradient;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: foregroundColor ?? Colors.white,
      leading: leading,
      actions: actions,
      bottom: bottom as PreferredSizeWidget?,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            backgroundImage != null
                ? backgroundImage!
                : GradientBackground(colors: colors, child: Container()),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),

            // Glass effect for the bottom area if useGlass is true
            if (useGlass)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        theme.customColors.glassBackground,
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Glass Search Bar that can be used within other screens
class GlassSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const GlassSearchBar({
    super.key,
    this.hintText = 'Search music...',
    this.onChanged,
    this.onSubmitted,
    this.margin,
    this.padding,
  });

  @override
  State<GlassSearchBar> createState() => _GlassSearchBarState();
}

class _GlassSearchBarState extends State<GlassSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
      widget.onChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      child: GlassTextField(
        controller: _controller,
        hintText: widget.hintText,
        padding: widget.padding ?? const EdgeInsets.all(20),
        prefixIcon: const Icon(Icons.search, color: Colors.white, size: 24),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  _controller.clear();
                },
              )
            : null,
        onChanged: widget.onChanged,
      ),
    );
  }
}
