import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/NewsModel.dart';

class NewsService {
  final String _apiUrl = 'https://culiacan.tecnm.mx/wp-json/wp/v2/posts?_embed';

  Future<List<NewsModel>> getLatestNews({String query = ''}) async {
    String url = _apiUrl;
    
    if (query.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(query)}';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
          "Accept": "application/json"
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> posts = json.decode(response.body);

        return posts.map((post) {
          String title = post['title']?['rendered'] ?? 'Sin título';
          String content = post['content']?['rendered'] ?? 'Sin contenido.';
          String imageUrl = 'https://picsum.photos/seed/itc/500/300';
          
          try {
            if (post['_embedded'] != null && 
                post['_embedded']['wp:featuredmedia'] != null && 
                post['_embedded']['wp:featuredmedia'].isNotEmpty) {
              imageUrl = post['_embedded']['wp:featuredmedia'][0]['source_url'];
            }
          } catch (e) {
          }

          return NewsModel(
            title: title,
            imageUrl: imageUrl,
            content: content,
          );
        }).toList();
        
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API del Tec: $e');
    }
  }
}