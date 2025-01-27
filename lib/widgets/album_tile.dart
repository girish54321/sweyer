/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:nt4f04unds_widgets/nt4f04unds_widgets.dart';
import 'package:sweyer/sweyer.dart';

/// Needed for scrollbar computations.
const double kAlbumTileHeight = kAlbumTileArtSize + _tileVerticalPadding * 2;
const double _tileVerticalPadding = 8.0;
const double _horizontalPadding = 16.0;

class AlbumTile extends SelectableWidget<SelectionEntry> {
  const AlbumTile({
    Key key,
    @required this.album,
    this.trailing,
    this.current,
    this.onTap,
    this.small = false,
    double horizontalPadding,
  })  : assert(album != null),
        horizontalPadding = horizontalPadding ?? (small ? kSongTileHorizontalPadding : _horizontalPadding),
        index = null,
        super(key: key);

  const AlbumTile.selectable({
    Key key,
    @required this.album,
    @required this.index,
    @required SelectionController<SelectionEntry> selectionController,
    bool selected = false,
    this.trailing,
    this.current,
    this.onTap,
    this.small = false,
    double horizontalPadding,
  })  : assert(album != null),
        assert(index != null),
        assert(selectionController != null),
        assert(selectionController is SelectionController<SelectionEntry<Content>> ||
               selectionController is SelectionController<SelectionEntry<Song>>),
        horizontalPadding = horizontalPadding ?? (small ? kSongTileHorizontalPadding : _horizontalPadding),
        super.selectable(
          key: key,
          selected: selected,
          selectionController: selectionController,
        );

  final Album album;
  final int index;

  /// Widget to be rendered at the end of the tile.
  final Widget trailing;

  /// Whether this album is currently playing, if yes, enables animated
  /// [CurrentIndicator] over the ablum art.
  /// 
  /// If not specified, by default true if album is `currentSongOrigin` or
  /// if it's currently playing persistent playlist:
  /// 
  /// ```dart
  /// return album == ContentControl.state.currentSongOrigin ||
  ///        album == ContentControl.state.queues.persistent;
  /// ```
  final bool current;
  final VoidCallback onTap;

  /// Creates a small variant of the tile with the sizes of [SelectableTile].
  final bool small;
  final double horizontalPadding;

  @override
  SelectionEntry<Album> toSelectionEntry() => SelectionEntry<Album>(
    index: index,
    data: album,
  );

  @override
  _AlbumTileState createState() => _AlbumTileState();
}

class _AlbumTileState extends SelectableState<AlbumTile> {
  void _handleTap() {
    super.handleTap(() {
      if (widget.onTap != null) {
        widget.onTap();
      }
      HomeRouter.instance.goto(HomeRoutes.factory.album(widget.album));
    });
  }

  bool get current {
    if (widget.current != null)
      return widget.current;
    final album = widget.album;
    return album == ContentControl.state.currentSongOrigin ||
           album == ContentControl.state.queues.persistent;
  }

  Widget _buildTile() {
    return InkWell(
      onTap: _handleTap,
      onLongPress: toggleSelection,
      splashFactory: NFListTileInkRipple.splashFactory,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding,
          vertical: _tileVerticalPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: widget.small
                ? AlbumArt.songTile(
                    source: AlbumArtSource(
                      path: widget.album.albumArt,
                      contentUri: widget.album.contentUri,
                      albumId: widget.album.id,
                    ),
                    current: current,
                  )
                : AlbumArt.albumTile(
                    source: AlbumArtSource(
                      path: widget.album.albumArt,
                      contentUri: widget.album.contentUri,
                      albumId: widget.album.id,
                    ),
                    current: current,
                  ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.album.album,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ThemeControl.theme.textTheme.headline6,
                    ),
                    ArtistWidget(
                      artist: widget.album.artist,
                      textStyle: const TextStyle(fontSize: 14.0, height: 1.0),
                    )
                  ],
                ),
              ),
            ),
            if (widget.trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: widget.trailing,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!selectable)
      return _buildTile();
    return Stack(
      children: [
        _buildTile(),
        Positioned(
          left: kAlbumTileArtSize + 2.0,
          bottom: 2.0,
          child: SelectionCheckmark(animation: animation),
        ),
      ],
    );
  }
}
