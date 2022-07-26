import 'package:flutter/material.dart' hide Image;
import 'package:my_dog_app/models/image_model.dart';
import 'package:my_dog_app/services/network_service.dart';
import 'package:my_dog_app/views/collection_view.dart';
import 'package:my_dog_app/views/gallery_view.dart';

class HomeScreen extends StatefulWidget {
  final int crossAxisCount;
  const HomeScreen({Key? key, this.crossAxisCount = 2}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController controller = PageController(keepPage: true);
  int currentScreen = 0;
  List<Image> allImage = [];

  int get limit {
    return widget.crossAxisCount * 15;
  }

  void pressButton(int screen) {
    currentScreen = screen;
    controller.jumpToPage(screen);
    setState(() {});
  }

  void onScreenChanged(int screen) {
    currentScreen = screen;
    setState(() {});
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        title: Container(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:[Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // #all
                ElevatedButton(
                  onPressed: () => pressButton(0),
                  style: ElevatedButton.styleFrom(
                    primary: currentScreen == 0 ? Colors.black : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: const StadiumBorder(),
                  ),
                  child: Text("All", style: TextStyle(color: currentScreen == 0 ? Colors.white : Colors.black, fontSize: 20),),
                ),

                // #me
                ElevatedButton(
                  onPressed: () => pressButton(1),
                  style: ElevatedButton.styleFrom(
                    primary: currentScreen == 1 ? Colors.black : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: const StadiumBorder(),
                  ),
                  child: Text("Wallpapers", style: TextStyle(color: currentScreen == 1 ? Colors.white : Colors.black, fontSize: 20),),
                ),
                ElevatedButton(
                  onPressed: () => pressButton(2),
                  style: ElevatedButton.styleFrom(
                    primary: currentScreen == 2 ? Colors.black : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: const StadiumBorder(),
                  ),
                  child: Text("Recipes", style: TextStyle(color: currentScreen == 2 ? Colors.white : Colors.black, fontSize: 20),),
                ),
                ElevatedButton(
                  onPressed: () => pressButton(3),
                  style: ElevatedButton.styleFrom(
                    primary: currentScreen == 3 ? Colors.black : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: const StadiumBorder(),
                  ),
                  child: Text("Health", style: TextStyle(color: currentScreen == 3 ? Colors.white : Colors.black, fontSize: 20),),
                ),
              ],
            ),],
          ),
        ),
      ),
      body: PageView(
        controller: controller,
        onPageChanged: onScreenChanged,
        children: [
          GalleryView(api: NetworkService.API_GET_ALL_IMAGES, crossAxisCount: widget.crossAxisCount, params: NetworkService.paramsEmpty(),),
          CollectionView(api: NetworkService.API_SEARCH_COLLECTIONS, crossAxisCount: widget.crossAxisCount, params: NetworkService.paramToSearchCollectionOrUsers(query: "Wallpapers"),),
          CollectionView(api: NetworkService.API_SEARCH_COLLECTIONS, crossAxisCount: widget.crossAxisCount, params: NetworkService.paramToSearchCollectionOrUsers(query: "recipes"),),
          CollectionView(api: NetworkService.API_SEARCH_COLLECTIONS, crossAxisCount: widget.crossAxisCount, params: NetworkService.paramToSearchCollectionOrUsers(query: "health"),),
        ],
      ),
    );
  }
}

