/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';
import 'package:sweyer/sweyer.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:sweyer/constants.dart' as Constants;

const double _kIconSize = 22.0;
const double _kButtonSize = 66.0;

class AnimatedPlayPauseButton extends StatefulWidget {
  AnimatedPlayPauseButton({Key key, this.iconSize, this.size, this.iconColor})
      : super(key: key);

  final double iconSize;
  final double size;
  final Color iconColor;

  AnimatedPlayPauseButtonState createState() => AnimatedPlayPauseButtonState();
}

class AnimatedPlayPauseButtonState extends State<AnimatedPlayPauseButton>
    with TickerProviderStateMixin {
  AnimationController controller;
  StreamSubscription<PlayerState> _playerStateSubscription;

  String _animation;
  set animation(String value) {
    setState(() {
      _animation = value;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (MusicPlayer.playerState == PlayerState.PLAYING) {
      _animation = 'pause';
    } else {
      controller.value = 1.0;
      _animation = 'play';
    }

    _playerStateSubscription = MusicPlayer.onStateChange.listen((event) {
      /// Do not handle [PlayerState.PLAYING] as it's not the state the player will remain for long time.
      /// It will start playing next song immediately.
      if (event == PlayerState.PLAYING) {
        _pause();
      } else if (event == PlayerState.PAUSED) {
        _play();
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  void _play() {
    if (_animation != 'pause_play' && _animation != 'play') {
      controller.forward();
      animation = 'pause_play';
    }
  }

  void _pause() {
    if (_animation != 'play_pause' && _animation != 'pause') {
      controller.reverse();
      animation = 'play_pause';
    }
  }

  void _handlePress() {
    MusicPlayer.playPause();
  }

  @override
  Widget build(BuildContext context) {
    final baseAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final slideAnimation = Tween(
      begin: Offset.zero,
      end: const Offset(0.05, 0.0),
    ).animate(baseAnimation);
    final scaleAnimation = Tween(begin: 1.05, end: 0.89).animate(baseAnimation);
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final color = widget.iconColor ?? ThemeControl.theme.iconTheme.color;
    return NFIconButton(
      size: textScaleFactor * (widget.size ?? _kButtonSize),
      iconSize: textScaleFactor * (widget.iconSize ?? _kIconSize),
      onPressed: _handlePress,
      icon: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          // Needed because for some reason the color is not updated on theme change.
          key: ValueKey(color),
          child: FlareActor(
            Constants.Assets.ASSET_ANIMATION_PLAY_PAUSE,
            animation: _animation,
            callback: (value) {
              if (value == 'pause_play' && _animation != 'play_pause') {
                animation = 'play';
              } else if (value == 'play_pause' && _animation != 'pause_play') {
                animation = 'pause';
              }
            },
            color: color,
          ),
        ),
      ),
    );
  }
}
