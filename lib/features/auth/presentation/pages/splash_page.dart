import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                SvgPicture.asset(
                  'assets/iconssvg/cash.svg',
                  height: 27,
                  width: 28.5,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "PocketTrack",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'Geist',
                color: Colors.black,
              ),
            ),
            const Text(
              "Har bir tiyinni hisobga oling",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Geist',
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
