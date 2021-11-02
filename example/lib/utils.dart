import 'package:flutter/foundation.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

shareUrl(String url) {
  if (kIsWeb) {
    _maybeLaunchURL(url);
  } else {
    Share.share(url);
  }
}

void _maybeLaunchURL(url) async =>
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
