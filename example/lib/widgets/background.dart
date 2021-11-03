import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({Key? key, this.child, this.isWideScreen = false})
      : super(key: key);
  final Widget? child;
  final bool isWideScreen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Image.asset(
            'assets/dog_face.jpg',
            repeat: ImageRepeat.repeat,
            height: constraints.maxHeight,
            width: constraints.maxWidth,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen
                  ? constraints.maxWidth / 12
                  : constraints.maxWidth / 5,
              vertical: constraints.maxHeight / 12,
            ),
            child: child,
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                  'All the cute dog images are fetched from dog.ceo API ❤️'),
            ),
          ),
        ],
      );
    });
  }
}
