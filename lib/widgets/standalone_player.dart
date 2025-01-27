/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'dart:async';
import 'dart:ui';

import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';
import 'package:sweyer/sweyer.dart';

// I was just playing around with UI and saved this file for future use.
// Currently it's not used anywhere.

class _StandalonePlayer extends StatefulWidget {
  _StandalonePlayer({Key key}) : super(key: key);

  @override
  _StandalonePlayerState createState() => _StandalonePlayerState();
}

class _StandalonePlayerState extends State<_StandalonePlayer> with SingleTickerProviderStateMixin {
  AudioPlayer player;
  AnimationController controller;
  Timer timer;
  static const fadeDuration = Duration(milliseconds: 300);

  @override
  void initState() { 
    super.initState();
    controller = AnimationController(vsync: this, duration: fadeDuration);
    MusicPlayer.instance.pause();
    player = AudioPlayer();
    // player.setAsset();
    // player.play();
    player.processingStateStream.listen((state) {
      if (player.processingState == ProcessingState.completed && player.playing) {
        _show();
        player.pause();
      }
    });
  }

  @override
  void dispose() { 
    timer?.cancel();
    controller.dispose();
    player.dispose();
    super.dispose();
  }

  void _show() {
    controller.forward();
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 1500) + fadeDuration, () {
      controller.reverse();
    });
  }

  void _handleTap() {
    _show();
    setState(() {
      if (player.processingState == ProcessingState.completed) {
        player.seek(const Duration());
      }
      if (player.playing) {
        player.pause();
      } else {
        player.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                children: [
                  const AlbumArt.playerRoute(
                    source: null,
                    borderRadius: 0,
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _handleTap,
                      child: AnimatedBuilder(
                        animation: controller,
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.black38,
                          child: IgnorePointer(
                            child: AnimatedPlayPauseButton(
                              player: player,
                              iconSize: 46,
                            ),
                          ),
                        ),
                        builder: (context, child) {
                          final fadeAnimation = CurvedAnimation(
                            curve: Curves.easeOut,
                            reverseCurve: Curves.easeIn,
                            parent: controller,
                          );
                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: child,
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Seekbar(
                color: Colors.white,
                duration: const Duration(seconds: 215),
                player: player,
              )
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
void _openStandalonePlayerRoute(BuildContext context) {
  var popped = false;
  Navigator.of(context).push(
    RouteTransitionBuilder(
      transitionSettings: RouteTransitionSettings(opaque: false, transitionDuration: const Duration(milliseconds: 500)),
      builder: (context) => _StandalonePlayer(),
      animationBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic), 
          reverseCurve: const Interval(0.0, 0.8, curve: Curves.easeInCubic), 
        );
        final routeScaleAnimation = Tween(
          begin: 0.87,
          end: 1.0
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic), 
          reverseCurve: const Interval(0.3, 1.0, curve: Curves.easeInCubic), 
        ));
        final routeFadeAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic), 
          reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeInCubic), 
        );
        final value = fadeAnimation.value * 20.0;
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (!popped) {
                      popped = true;
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(color: ThemeControl.theme.colorScheme.primary.withOpacity(0.4 * fadeAnimation.value)),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: value,
                    sigmaY: value,
                  ),
                  child: ScaleTransition(
                    scale: routeScaleAnimation,
                    child: FadeTransition(
                      opacity: routeFadeAnimation,
                      child: child,
                    ),
                  ),
                ),
              ],
            );
          }
        );
      }
    ),
  );
}