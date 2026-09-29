import 'dart:async';
import 'package:flutter/material.dart';
import '../models/NewsModel.dart';
import '../services/NewsServices.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsService _newsServices = NewsService();

  List<NewsModel> newList = []; 
  bool isLoading = true;
  String errorMessage = '';

  Timer? _debounce;

  NewsViewModel() {
    fetchNews();
  }

  Future<void> fetchNews([String query = '']) async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      newList = await _newsServices.getLatestNews(query: query);

    } catch (e) {
      errorMessage = 'No se pudieron cargar las noticias. Verifica tu conexión.';
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchNews(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}