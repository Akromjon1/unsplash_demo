import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:my_dog_app/models/single_photo_model.dart';
import 'package:my_dog_app/services/network_service.dart';
import 'package:my_dog_app/services/util_service.dart';
import 'package:my_dog_app/views/collection_view.dart';
import 'package:my_dog_app/views/gallery_view.dart';
import 'package:permission_handler/permission_handler.dart';

class DetailPage extends StatefulWidget {
  final int crossAxisCount;
  final SinglePhotoModel image;

  const DetailPage({Key? key, required this.image, this.crossAxisCount = 2}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late SinglePhotoModel image;


  @override
  void initState() {
    super.initState();
    _convertData();
  }
  void _convertData () async{
    image = widget.image;
    setState(() {});
  }
  _setWallpaper(location) async{
      if(location == "lock"){
        int location = WallpaperManager.LOCK_SCREEN;
        var file = await DefaultCacheManager().getSingleFile(image.urls!.regular!);
        bool result = await WallpaperManager.setWallpaperFromFile(file.path, location); //provide image path
        print(result);
      }else if(location == "home"){
        int location = WallpaperManager.HOME_SCREEN;
        var file = await DefaultCacheManager().getSingleFile(image.urls!.regular!);
        bool result = await WallpaperManager.setWallpaperFromFile(file.path, location);
        print(result);

      }else{
        int location = WallpaperManager.BOTH_SCREEN;
        var file = await DefaultCacheManager().getSingleFile(image.urls!.regular!);
        bool result = await WallpaperManager.setWallpaperFromFile(file.path, location);
        print(result);

      }
      if(mounted) Navigator.pop(context);

  }
  void _getWallpaper() {
    showModalBottomSheet(

      context: context,
      builder: (context) => Container(
        height: 200,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.screen_lock_rotation),
              title: const Text("Lock screen"),
              onTap: (){
                _setWallpaper("lock");
              }
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text("Home screen"),
                onTap: (){
                  _setWallpaper("home");
                }
            ),
            ListTile(
              leading: const Icon(Icons.two_k),
              title: const Text("Both screen"),
                onTap: (){
                  _setWallpaper("b");
                }
            ),
          ],
        ),
      ),
    );
  }
  _save() async {
    var status = await Permission.storage.request();
    if(status.isGranted){
      var res = await NetworkService.GET("${NetworkService.API_GET_ALL_IMAGES}/${image.id}/download",
          {});
      if(res != null){
        var decodedRes = jsonDecode(res);
        var urlForDownload = decodedRes["url"];
        var response = await Dio().get(
            urlForDownload,
            options: Options(responseType: ResponseType.bytes));
        final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.data),
            quality: 60,
            name: "${image.id}");
        print(result);
      }else {
        print("Error");
      }

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            splashRadius: 35,
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_outlined, size: 30,),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              foregroundDecoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.1),
                      ]
                  )
              ),
              child: AspectRatio(
                aspectRatio: (image.width! /100) / (image.height! /100),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: image.urls!.regular!,
                  placeholder: (context, url) => Container(
                    color: Colors.primaries[Random().nextInt(18) % 18],
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: image.user!.profileImage!.small != null ? NetworkImage(image.user!.profileImage!.small!): NetworkImage(image.urls!.regular!),
                    ),
                    title: image.user!.firstName !=null ? Text(image.user!.firstName!):const Text("No name"),
                    subtitle: image.user!.instagramUsername != null ? Text(image.user!.instagramUsername!): const Text("No instagram profile"),
                    trailing: Container(
                      height: 40,
                      width: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300]!,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Center(
                        child: Text("Follow"),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(onPressed: (){}, icon: const Icon(CupertinoIcons.chat_bubble_fill, size: 30,)),

                      GestureDetector(
                        onTap: () {
                          if(Platform.isAndroid){
                            _getWallpaper();
                          }else{
                            Util.fireSnackBar("Firstly change your device to Android", context);
                          }
                        },
                        child: Container(
                          height: 50,
                          width: 110,
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Center(
                            child: Text("Set as wallpaper", overflow: TextOverflow.ellipsis,),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          _save();
                        },
                        child: Container(
                          height:  50,
                          width: 110,
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Center(
                            child: Text("Save", style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ),
                        IconButton(onPressed: (){}, icon: const Icon(Icons.share, size: 30,))

                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 2,),
            Container(
              constraints:  BoxConstraints(
                minWidth: double.infinity,
                  minHeight: MediaQuery.of(context).size.height
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: GalleryView(api: "${NetworkService.API_GET_USERS_PHOTOS}${image.user!.username}/photos", crossAxisCount: widget.crossAxisCount, params: NetworkService.paramsEmpty(), physics: const NeverScrollableScrollPhysics(),),

            ),
          ],
        ),
      ),
    );
  }
}
