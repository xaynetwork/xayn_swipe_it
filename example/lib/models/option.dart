import 'package:flutter/material.dart';

@immutable
class Option {
  final String option;
  final Color color;

  const Option._(this.option, this.color);

  static const Option share = Option._('share', Colors.blue);
  static const Option like = Option._('like', Colors.green);
  static const Option dislike = Option._('dislike', Colors.red);
  static const Option skip = Option._('skip', Colors.yellow);
  static const Option neutral = Option._('neutral', Colors.white60);

  @override
  String toString() => option;
}

extension OptionUtils on Option {
  get icon {
    switch (this) {
      case Option.share:
        return Icons.share;
      case Option.dislike:
        return Icons.thumb_down_alt_rounded;
      case Option.like:
        return Icons.thumb_up_alt_rounded;
      case Option.skip:
        return Icons.refresh;
      case Option.neutral:
        return Icons.remove_circle_outline;
    }
  }
}
