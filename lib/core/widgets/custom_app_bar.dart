import 'package:flutter/material.dart';

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
  });

  @override
  Widget build(BuildContext context) {
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
  final List<Color> gradientColors;
  final Color? foregroundColor;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.gradientColors = const [Color(0xFF667eea), Color(0xFF764ba2)],
    this.foregroundColor = Colors.white,
    this.onBackPressed,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        foregroundColor: foregroundColor,
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

  const SearchAppBar({
    super.key,
    this.hintText = 'Search...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClearPressed,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
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
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        background: backgroundImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  backgroundImage!,
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
