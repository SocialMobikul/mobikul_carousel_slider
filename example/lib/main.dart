import 'package:flutter/material.dart';
import 'package:mobikul_carousel_slider/mobikul_carousel_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carousel Slider Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CarouselDemo(),
    );
  }
}

class CarouselDemo extends StatelessWidget {
  const CarouselDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Slider Example'),
      ),
      body: Center(
        child: MobikulCarouselSlider(
          items: [
            Image.network('imageURL1'),
            Image.network('imageURL2'),
            Image.network('imageURL3'),
          ],
          autoPlay: true,
          loop: true,
          showIndicators: true,
          indicatorAlignment: Alignment.bottomCenter,
          scrollDirection: Axis.horizontal,
          transitionDuration: const Duration(milliseconds: 800),
        ),
      ),
    );
  }
}
