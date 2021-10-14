import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share/share.dart';

import 'package:photoapp/photo.dart';
import 'package:photoapp/providers.dart';

class PhotoViewScreen extends StatefulWidget {
  @override
  _PhotoViewScreenState createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: context.read(photoViewInitialIndexProvider));
  }

  Future<void> _onTapShare() async {
    final photoList = context.read(photoListProvider).data!.value;
    final photo = photoList[_controller.page!.toInt()];

    await Share.share(photo.imageURL);
  }

  Future<void> _onTapDelete() async {
    final photoRepository = context.read(photoRepositoryProvider);
    final photoList = context.read(photoListProvider).data!.value;
    final photo = photoList[_controller.page!.toInt()];

    if (photoList.length == 1) {
      Navigator.of(context).pop();
    } else if (photoList.last == photo) {
      await _controller.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    await photoRepository!.deletePhoto(photo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // AppBarの裏までbodyの表示エリアを広げる
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Consumer(builder: (context, watch, child) {
            final asyncPhotoList = watch(photoListProvider);
            return asyncPhotoList.when(
              data: (photoList) {
                return PageView(
                  controller: _controller,
                  onPageChanged: (int index) => {},
                  children: photoList.map((Photo photo) {
                    return Image.network(
                      photo.imageURL,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                );
              },
              loading: () {
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (e, stackTrace) {
                return Center(
                  child: Text(e.toString()),
                );
              },
            );
          }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.bottomCenter,
                  end: FractionalOffset.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.5],
                ),
              ),
              child: SafeArea(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () => _onTapShare(),
                    color: Colors.white,
                    icon: Icon(Icons.share),
                  ),
                  IconButton(
                    onPressed: () => _onTapDelete(),
                    color: Colors.white,
                    icon: Icon(Icons.delete),
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}