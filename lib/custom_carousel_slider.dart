library custom_carousel_slider;

import 'dart:async';
import 'package:flutter/material.dart';

/// A function signature for handling carousel item changes.
typedef OnItemChangeCallback = void Function(int index);

/// A function signature for building custom carousel indicators.
typedef IndicatorBuilder = Widget Function(BuildContext context, int index, bool isActive);

/// A customizable carousel widget that supports auto-play, looping, and indicators.
class CustomCarousel extends StatefulWidget {
  /// List of widgets to display in the carousel.
  /// Each widget represents an item in the carousel.
  final List<Widget> items;

  /// Duration of the transition animation between pages.
  /// Defaults to 300 milliseconds.
  final Duration transitionDuration;

  /// Curve of the transition animation.
  /// Defaults to a linear curve.
  final Curve transitionCurve;

  /// Enables or disables auto-play functionality.
  /// When enabled, the carousel will automatically transition to the next item at regular intervals.
  final bool autoPlay;

  /// The interval between transitions when auto-play is enabled.
  /// Defaults to 3 seconds.
  final Duration autoPlayInterval;

  /// The initial page index to display when the carousel is first rendered.
  /// Defaults to 0.
  final int initialPage;

  /// Determines whether the carousel should loop back to the start after reaching the last item.
  /// If `false`, the carousel stops at the last item.
  final bool loop;

  /// Controls the visibility of the page indicators.
  final bool showIndicators;

  /// Alignment of the indicators on the carousel.
  /// Defaults to `Alignment.bottomCenter`.
  final Alignment indicatorAlignment;

  /// Size of each indicator dot.
  /// Defaults to 8.0.
  final double indicatorSize;

  /// Spacing between indicator dots.
  /// Defaults to 4.0.
  final double indicatorSpacing;

  /// Custom decoration to apply to each carousel item.
  /// Can be used to add rounded corners or shadows.
  final Decoration? itemDecoration;

  /// Padding to apply to each carousel item.
  final EdgeInsetsGeometry? itemPadding;

  /// The scroll direction of the carousel.
  /// Can be either `Axis.horizontal` or `Axis.vertical`.
  /// Defaults to `Axis.horizontal`.
  final Axis scrollDirection;

  /// Custom builder for rendering page indicators.
  /// Provides the index of the indicator and its active state.
  final IndicatorBuilder? indicatorBuilder;

  /// Callback triggered when the current carousel item changes.
  /// Provides the new index of the active item.
  final OnItemChangeCallback? onItemChange;

  /// Background color of the carousel container.
  final Color? backgroundColor;

  /// Background gradient of the carousel container.
  /// Takes precedence over `backgroundColor` if both are provided.
  final Gradient? backgroundGradient;

  /// Creates a [CustomCarousel] widget.
  ///
  /// All parameters are optional and have sensible defaults.
  const CustomCarousel({
    super.key,
    this.items = const [],
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.linear,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.initialPage = 0,
    this.loop = false,
    this.showIndicators = false,
    this.indicatorAlignment = Alignment.bottomCenter,
    this.indicatorSize = 8.0,
    this.indicatorSpacing = 4.0,
    this.itemDecoration,
    this.itemPadding,
    this.scrollDirection = Axis.horizontal,
    this.indicatorBuilder,
    this.onItemChange,
    this.backgroundColor,
    this.backgroundGradient,
  });

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentIndexNotifier;
  Timer? _autoPlayTimer;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentIndexNotifier = ValueNotifier<int>(
      widget.initialPage % (widget.items.isNotEmpty ? widget.items.length : 1),
    );
    _pageController = PageController(initialPage: _currentIndexNotifier.value);

    if (widget.autoPlay && widget.items.isNotEmpty) {
      _startAutoPlay();
    }
  }

  /// Starts the auto-play functionality, transitioning the carousel at regular intervals.
  void _startAutoPlay() {
    _isAutoPlaying = true;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || widget.items.isEmpty) return;

      int nextIndex = _currentIndexNotifier.value + 1;

      // If we have reached the end and looping is disabled, stop autoplay
      if (nextIndex >= widget.items.length) {
        if (widget.loop) {
          nextIndex = 0; // Loop back to the first item
        } else {
          _stopAutoPlay(); // Stop autoplay when reaching the last item
          return;
        }
      }

      _pageController.animateToPage(
        nextIndex,
        duration: widget.transitionDuration,
        curve: widget.transitionCurve,
      );
    });
  }

  /// Stops the auto-play functionality.
  void _stopAutoPlay() {
    _isAutoPlaying = false;
    _autoPlayTimer?.cancel();
  }

  /// Toggles the auto-play functionality on and off.
  void _toggleAutoPlay() {
    if (_isAutoPlaying) {
      _stopAutoPlay();
    } else {
      _startAutoPlay();
    }
  }

  /// Updates the current index when the page changes.
  void _onPageChanged(int index) {
    int itemCount = widget.items.length;

    // Ensure the index stays within bounds
    if (widget.loop) {
      // Looping behavior: reset the index when it goes out of bounds
      index = index % itemCount;
    } else {
      // Non-looping behavior: clamp index to valid range
      index = index.clamp(0, itemCount - 1);
    }

    if (_currentIndexNotifier.value != index) {
      _currentIndexNotifier.value = index;
      if (widget.onItemChange != null) {
        widget.onItemChange!(index);
      }
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  /// Builds the indicator dots for the carousel.
  Widget _buildIndicators() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndexNotifier,
      builder: (context, currentIndex, child) {
        return Align(
          alignment: widget.indicatorAlignment,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.items.length, (index) {
                bool isActive = index == currentIndex;
                return widget.indicatorBuilder != null
                    ? widget.indicatorBuilder!(context, index, isActive)
                    : AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: widget.indicatorSpacing / 2),
                  width: isActive ? widget.indicatorSize + 4 : widget.indicatorSize,
                  height: isActive ? widget.indicatorSize + 4 : widget.indicatorSize,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _toggleAutoPlay,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          gradient: widget.backgroundGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.items.length,
              scrollDirection: widget.scrollDirection,
              itemBuilder: (context, index) {
                final actualIndex = index % widget.items.length;
                Widget item = widget.items[actualIndex];

                if (widget.itemDecoration != null) {
                  item = ClipRRect(
                    borderRadius: (widget.itemDecoration as BoxDecoration?)?.borderRadius?.resolve(Directionality.of(context)) ?? BorderRadius.zero,
                    child: Container(
                      decoration: widget.itemDecoration,
                      child: item,
                    ),
                  );
                }

                if (widget.itemPadding != null) {
                  item = Padding(
                    padding: widget.itemPadding!,
                    child: item,
                  );
                }

                return item;
              },
            ),
            if (widget.showIndicators) _buildIndicators(),
          ],
        ),
      ),
    );
  }
}

