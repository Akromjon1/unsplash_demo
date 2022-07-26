import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_dog_app/models/image_model.dart' as model;
import 'package:my_dog_app/models/single_photo_model.dart';

class ImageView extends StatefulWidget {
  final SinglePhotoModel image;
  const ImageView({Key? key, required this.image}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {

  late SinglePhotoModel image;
  @override
  void initState() {
    super.initState();
    _convertData();
  }

  void _convertData() {
    image = widget.image;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: AspectRatio(
        aspectRatio: (image.height)! / 100 / (image.width! /100),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: image.urls!.small!,
          placeholder: (context, url) => Container(color: Colors.primaries[Random().nextInt(18) % 18],),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
