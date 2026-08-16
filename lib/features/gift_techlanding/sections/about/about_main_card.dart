import 'dart:ui';

import 'package:flutter/material.dart';

import 'about_shared.dart';

class AboutMainCard extends StatelessWidget {
  const AboutMainCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 700;

    return ClipRRect(
      borderRadius: BorderRadius.circular(isMobile ? 26 : 34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 26 : 54),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 26 : 34),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AboutColors.blue.withOpacity(0.12),
                Colors.white.withOpacity(0.035),
                AboutColors.navy.withOpacity(0.08),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.085)),
            boxShadow: [
              BoxShadow(
                color: AboutColors.blue.withOpacity(0.08),
                blurRadius: 70,
                spreadRadius: -15,
                offset: const Offset(0, 28),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: isMobile
              ? const _AboutMainMobile()
              : const _AboutMainDesktop(),
        ),
      ),
    );
  }
}

class _AboutMainDesktop extends StatelessWidget {
  const _AboutMainDesktop();

  @override
  Widget build(BuildContext context) {
    return Row(
      // IMPORTANT:
      // Never use CrossAxisAlignment.stretch here.
      //
      // The page is inside a vertical SingleChildScrollView,
      // which gives this Row an unbounded vertical constraint.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: const AboutStory()),

        const SizedBox(width: 70),

        Expanded(flex: 4, child: const AboutCompanySnapshot()),
      ],
    );
  }
}

class _AboutMainMobile extends StatelessWidget {
  const _AboutMainMobile();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [AboutStory(), SizedBox(height: 42), AboutCompanySnapshot()],
    );
  }
}

class AboutStory extends StatelessWidget {
  const AboutStory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AboutSmallLabel('THE COMPANY'),

        const SizedBox(height: 18),

        const Text(
          'One technology company.\nMultiple digital experiences.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 31,
            height: 1.08,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.1,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 22),

        Text(
          'Gift Technology Ltd is a Nigerian multinational technology company building secure digital platforms across payments, utilities, business services, digital entertainment, and emerging technology.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 15,
            height: 1.75,
            color: Colors.white.withOpacity(0.52),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Our approach is simple: build useful technology, connect it through reliable infrastructure, and create experiences that can grow with the people and businesses using them.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 15,
            height: 1.75,
            color: Colors.white.withOpacity(0.40),
          ),
        ),

        const SizedBox(height: 28),

        const AboutStats(),
      ],
    );
  }
}

class AboutStats extends StatelessWidget {
  const AboutStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 34,
      runSpacing: 18,
      children: const [
        _AboutStat(number: '01', label: 'Technology'),
        _AboutStat(number: '02', label: 'Infrastructure'),
        _AboutStat(number: '03', label: 'Ecosystem'),
      ],
    );
  }
}

class _AboutStat extends StatelessWidget {
  final String number;
  final String label;

  const _AboutStat({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Colors.white.withOpacity(0.30),
          ),
        ),
      ],
    );
  }
}

class AboutCompanySnapshot extends StatelessWidget {
  const AboutCompanySnapshot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.025),
        border: Border.all(color: Colors.white.withOpacity(0.065)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AboutSmallLabel('COMPANY PROFILE'),

          SizedBox(height: 22),

          _SnapshotRow(label: 'Company', value: 'Gift Technology Ltd'),

          _SnapshotDivider(),

          _SnapshotRow(label: 'Focus', value: 'Digital infrastructure'),

          _SnapshotDivider(),

          _SnapshotRow(label: 'Market', value: 'Africa'),

          _SnapshotDivider(),

          _SnapshotRow(label: 'Headquarters', value: 'Port Harcourt, Nigeria'),

          _SnapshotDivider(),

          _SnapshotRow(
            label: 'Approach',
            value: 'Technology · Infrastructure · Ecosystem',
          ),
        ],
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  final String label;
  final String value;

  const _SnapshotRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(0.24),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.66),
            ),
          ),
        ),
      ],
    );
  }
}

class _SnapshotDivider extends StatelessWidget {
  const _SnapshotDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withOpacity(0.055),
      ),
    );
  }
}
