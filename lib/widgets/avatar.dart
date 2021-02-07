import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Avatar extends StatefulWidget {
  final String avatarURL;
  final double radius;
  final bool isAnonymous;

  Avatar(this.avatarURL, this.radius, {this.isAnonymous = false});

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: widget.isAnonymous ? Colors.red : Colors.black54,
      child: Container(
        height: widget.radius * 2,
        width: widget.radius * 2,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: widget.avatarURL != null
                    ? CachedNetworkImage(
                        imageUrl: widget.avatarURL,
                        fit: BoxFit.cover,
                        useOldImageOnUrlChange: true,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )
                    : Icon(
                        FontAwesomeIcons.user,
                        size: 30,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
