import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/legacy.dart';

// =================== State ===================
class SliderState {
  final int currentIndex;
  SliderState({this.currentIndex = 0});

  SliderState copyWith({int? currentIndex}) {
    return SliderState(currentIndex: currentIndex ?? this.currentIndex);
  }
}

// =================== Notifier ===================
class SliderNotifier extends StateNotifier<SliderState> {
  SliderNotifier() : super(SliderState());

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

// =================== Provider ===================
final sliderProvider =
StateNotifierProvider<SliderNotifier, SliderState>((ref) {
  return SliderNotifier();
});

// =================== Widget ===================
class SliderWidget extends ConsumerWidget {
  final List<String> imgUrls;
  final double height;
  final double? bottom;
  final BorderRadius? borderRadius;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Color activeDotColor;
  final Color inactiveDotColor;
  final bool showDots;

  const SliderWidget({
    super.key,
    required this.imgUrls,
    this.bottom,
    this.borderRadius,
    this.height = 200,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.activeDotColor = Colors.white,
    this.inactiveDotColor = Colors.grey,
    this.showDots = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sliderProvider);
    final notifier = ref.read(sliderProvider.notifier);

    if (imgUrls.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final CarouselSliderController controller = CarouselSliderController();

    return Stack(
      children: [
        CarouselSlider(
          items: imgUrls.map((url) {
            return ClipRRect(
              borderRadius:borderRadius?? BorderRadius.circular(12),
              child: Image.network(
                url,
                fit: BoxFit.fill,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.red),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
          carouselController: controller,
          options: CarouselOptions(
            height: height,
            viewportFraction: 1,
            autoPlay: autoPlay,
            autoPlayInterval: autoPlayInterval,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              notifier.setCurrentIndex(index);
            },
          ),
        ),
        if (showDots)
        Positioned(
          bottom: bottom ?? 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgUrls.asMap().entries.map((entry) {
              final isActive = state.currentIndex == entry.key;
              return GestureDetector(
                onTap: () => controller.animateToPage(entry.key),
                child: Container(
                  width: isActive ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive ? activeDotColor : inactiveDotColor.withValues(alpha: 0.7),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}




