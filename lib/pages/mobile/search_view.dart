import 'package:flutter/material.dart';

import '../../services/network_service.dart';
import '../../views/collection_view.dart';

class SearchView extends StatefulWidget {
  final int crossAxisCount;
  const SearchView({Key? key, this.crossAxisCount = 2}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController searchController = TextEditingController();
  bool isSearch = false;
  String query ='';
  void search(){
   isSearch = true;
   query = searchController.text;
   FocusScope.of(context).unfocus();
   setState((){});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none
          ),
          controller: searchController,
          onTap: (){
            isSearch = false;
            setState((){});
          },
          onEditingComplete: search,
        ),
      ),
      body: isSearch ? CollectionView(api: NetworkService.API_SEARCH_COLLECTIONS, crossAxisCount: widget.crossAxisCount, params: NetworkService.paramToSearchCollectionOrUsers(query: query))
          :  const Center(child: Text("Please add your query and press search button to see the result", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),),
    );
  }
}
