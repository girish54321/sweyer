/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_music_player/flutter_music_player.dart';
import 'package:flutter_music_player/constants.dart' as Constants;

class AnimatedPlayPauseButton extends StatefulWidget {
  AnimatedPlayPauseButton({Key key, this.isLarge = false}) : super(key: key);

  /// Creates button of big size
  final bool isLarge;

  AnimatedPlayPauseButtonState createState() => AnimatedPlayPauseButtonState();
}

class AnimatedPlayPauseButtonState extends State<AnimatedPlayPauseButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  StreamSubscription<AudioPlayerState> _playerChangeSubscription;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    if (MusicPlayer.playState == AudioPlayerState.PLAYING) {
      _animationController.value = 1;
    } else {
      _animationController.value = 0;
    }

    _playerChangeSubscription =
        MusicPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        if (event == AudioPlayerState.PLAYING) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    });
  }

  void _handlePress() async {
    await MusicPlayer.playPause();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: CustomIconButton(
      iconSize: 32,
      splashColor: Constants.AppTheme.splash.auto(context),
      size: 56,
      icon: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        color: Constants.AppTheme.playPauseIcon.auto(context),
        progress: _animationController,
      ),
      onPressed: _handlePress,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _playerChangeSubscription.cancel();
    super.dispose();
  }
}