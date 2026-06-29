import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/NewsViewModel.dart';
import 'NewsDetail.dart';

class News extends StatelessWidget {
  const News({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A365D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<NewsViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (viewModel.errorMessage.isNotEmpty) {
                      return Center(
                        child: Text(
                          viewModel.errorMessage,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (viewModel.newList.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay noticias disponibles en este momento.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: viewModel.newList.length,
                      itemBuilder: (context, index) {
                        final newsItem = viewModel.newList[index];
                        return _buildNewsCard(
                          context: context,
                          title: newsItem.title,
                          imageUrl: newsItem.imageUrl,
                          content: newsItem.content,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Buscar noticia...',
          hintStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(Icons.search, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildNewsCard({
    required BuildContext context,
    required String title,
    required String imageUrl,
    required String content,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetail(
              title: title,
              imageUrl: imageUrl,
              content: content,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5FA),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              imageUrl,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A365D),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}