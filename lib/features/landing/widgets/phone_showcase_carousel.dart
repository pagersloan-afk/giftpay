import 'dart:async';
import 'package:flutter/material.dart';

class PhoneShowcaseCarousel extends StatefulWidget {
  final List<String> screens;
  final double height;

  const PhoneShowcaseCarousel({
    super.key,
    required this.screens,
    this.height = 400,
  });

  @override
  State<PhoneShowcaseCarousel> createState() => _PhoneShowcaseCarouselState();
}

class _PhoneShowcaseCarouselState extends State<PhoneShowcaseCarousel> {
  int index = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        index = (index + 1) % widget.screens.length;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
            widget.screens[index],
            key: ValueKey(index),
            height: widget.height,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
