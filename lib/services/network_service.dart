import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_parser/http_parser.dart';
import 'package:my_dog_app/services/interceptor_service.dart';
import 'package:my_dog_app/services/log_service.dart';

class NetworkService {
  // baseUrl
  static const isTester = true;

  static const DEVELOPMENT_SERVER = "api.unsplash.com";
  static const DEPLOYMENT_SERVER = "api.unsplash.com";


  static String get BASEURL {
    if(isTester) {
      return DEVELOPMENT_SERVER;
    } else {
      return DEPLOYMENT_SERVER;
    }
  }

  // apis
  static const API_LIST_BREADS = "/v1/breeds";
  static const API_BREADS_SEARCH = "/v1/breeds/search";
  static const API_LIST_VOTES = "/v1/votes";
  static const API_ONE_VOTE = "/v1/votes/"; // {ID}
  static const API_IMAGE_LIST = "/v1/images/search";
  static const API_IMAGE_UPLOAD = "/v1/images/upload";
  static const API_MY_IMAGES = "/v1/images";
  static const String API_GET_ALL_IMAGES = "/photos";
  static const String API_LIST_COLLECTIONS = "/collections";
  static const String API_SEARCH_COLLECTIONS = "/search/photos";
  static const String API_GET_USERS_PHOTOS= "/users/";



  // headers
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Client-ID 7abE06yGKJfCKMMI93kyIdtx5MTc_6sZ3hvuQC4vtro',
  };

  static Map<String, String> headersForUpload = {
    'Content-Type': 'multipart/form-data',
    'x-api-key': '19abbefc-b253-4f39-a7ee-769267b6cd56',
  };

  // interceptor
  static final http = InterceptedHttp.build(interceptors: [
    InterceptorService(),
  ]);

  // methods
  static Future<String?> GET(String api, Map<String, String> params) async{
    Uri url = Uri.https(BASEURL, api, params);
    final response = await http.get(url, headers: headers);

    if(response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  static Future<String?> POST(String api, Map<String, String> params, Map<String, dynamic> body,) async{
    Uri url = Uri.https(BASEURL, api);
    final response = await http.post(url, headers: headers, body: jsonEncode(body), params: params);

    if(response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  static Future<String?> PUT(String api, Map<String, String> params, Map<String, dynamic> body,) async{
    Uri url = Uri.https(BASEURL, api, params);
    final response = await http.put(url, headers: headers, body: jsonEncode(body));

    if(response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  static Future<String?> PATCH(String api, Map<String, String> params, Map<String, dynamic> body,) async{
    Uri url = Uri.https(BASEURL, api, params);
    final response = await http.patch(url, headers: headers, body: jsonEncode(body));

    if(response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  static Future<String?> DELETE(String api, Map<String, String> params) async{
    Uri url = Uri.https(BASEURL, api, params);
    final response = await http.delete(url, headers: headers);

    if(response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  static Future<String?> MULTIPART(String api, String filePath, Map<String, String> body) async {
    var uri = Uri.https("api.thedogapi.com", api);
    var request = MultipartRequest('POST', uri);
    request.headers.addAll((headersForUpload));
    request.files.add(await MultipartFile.fromPath('file', filePath, contentType: MediaType("image", "jpeg")));
    request.fields.addAll(body);
    StreamedResponse response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      LogService.o(response.reasonPhrase.toString());
      LogService.o(response.statusCode.toString());
      return await response.stream.bytesToString();
    } else {
      LogService.e(response.reasonPhrase.toString());
      return response.reasonPhrase;
    }
  }


  // params
  static Map<String, String> paramsEmpty() {
    Map<String, String> map = {};
    return map;
  }

  static Map<String, String> paramsBreedSearch(String queryName) {
    Map<String, String> map = {
      'q': queryName
    };
    return map;
  }

  static Map<String, String> paramsVotesList({int limit = 10, int page = 0, String? subId}) {
    Map<String, String> map = {
      'limit': limit.toString(),
      'page': page.toString()
    };
    if(subId != null) {
      map.addAll({"sub_id": subId});
    }
    return map;
  }

  static Map<String, String> paramsImageSearch({String size = "med", List<String>? mimeType, String order = "RANDOM", int limit = 10, int page = 0, List<int>? categoryIds, String format = "json", String? breedId}) {
    // size: full, med, small, thumb
    // order: RANDOM, ASC, DESC
    // format: json, src
    Map<String, String> map = {
      'limit': limit.toString(),
      'page': page.toString(),
      'size': size,
      'order': order,
      'format': format,
    };
    if(mimeType != null) map.addAll({"mime_types": jsonEncode(mimeType)});
    if(categoryIds != null) map.addAll({"category_ids": jsonEncode(categoryIds)});
    if(breedId != null) map.addAll({"breed_id": breedId});

    return map;
  }
  static Map<String, String> paramToSearchCollectionOrUsers({
    required String query,
    int page = 1,
    int perPage = 10,
  }) {
    return {
      'query': query,
      'page': '$page',
      'per_page': '$perPage',
    };
  }
  static Map<String, String> paramToGetImages({
    int page = 1,
    int perPage = 15,
    String orderBy = 'latest',
  }) {
    return {
      'page': '$page',
      'per_page': '$perPage',
      'order_by': orderBy,
    };
  }

  static Map<String, String> paramsMyImage({List<String>? breedsId, String order = "RANDOM", int limit = 10, int page = 0, List<String>? categoryIds, String format = "json", String? subId, String? originalFileName, int? includeVote, int? includeFavorite}) {
    // order: RANDOM, ASC, DESC
    // format: json, src
    Map<String, String> map = {
      'limit': limit.toString(),
      'page': page.toString(),
      'order': order,
      'format': format,
    };

    if(breedsId != null) map.addAll({"breed_ids": jsonEncode(breedsId)});
    if(categoryIds != null) map.addAll({"category_ids": jsonEncode(categoryIds)});
    if(subId != null) map.addAll({"sub_id": subId});
    if(originalFileName != null) map.addAll({"original_filename": originalFileName});
    if(includeVote != null) map.addAll({"include_vote": includeVote.toString()});
    if(includeFavorite != null) map.addAll({"include_favorite": includeFavorite.toString()});

    return map;
  }


  // bodies
  static Map<String, dynamic> bodyVotes(String imageId, String subId, int value) {
    Map<String, dynamic> map = {
      "image_id": imageId,
      "sub_id": subId,
      "value": value
    };
    return map;
  }

  static Map<String, String> bodyImageUpload(String subId) {
    Map<String, String> map = {
      "sub_id": subId,
    };
    return map;
  }

  // parsing
}