import 'package:flutter/material.dart';
import 'package:phimhayokup/utils/app_colors.dart';

class PhimhayLogo extends StatelessWidget {
  final double width;
  final bool showTagline;

  const PhimhayLogo({
    super.key,
    this.width = 320,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilmStrip(width: width),
          Container(
            width: width,
            color: const Color(0xFF0F0F0F),
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Text(
                  'phimhay',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: width * 0.22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                    height: 1.0,
                  ),
                ),
                if (showTagline) ...[
                  const SizedBox(height: 12),
                  Text(
                    'XEM PHIM CHẤT LƯỢNG CAO',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 10,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _FilmStrip(width: width),
        ],
      ),
    );
  }
}

class _FilmStrip extends StatelessWidget {
  final double width;

  static const _filmBg = Color(0xFF1C1C1C);
  static const _holeBg = Color(0xFF060606);
  static const _holeW = 20.0;
  static const _holeH = 16.0;
  static const _stripH = 32.0;

  const _FilmStrip({required this.width});

  @override
  Widget build(BuildContext context) {
    final count = (width / 38).floor().clamp(1, 30);
    return Container(
      width: width,
      height: _stripH,
      color: _filmBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          count,
          (_) => Container(
            width: _holeW,
            height: _holeH,
            decoration: BoxDecoration(
              color: _holeBg,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
