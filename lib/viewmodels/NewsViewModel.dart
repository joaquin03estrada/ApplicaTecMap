import 'package:flutter/material.dart';
import '../models/NewsModel.dart';
import '../services/NewsServices.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsService _newsServices = NewsService();

  List<NewsModel> newList = []; 
  bool isLoading = true;
  String errorMessage = '';

  NewsViewModel() {
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      newList = await _newsServices.getLatestNews();

    } catch (e) {
      errorMessage = 'No se pudieron cargar las noticias. Verifica tu conexión.';
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}