
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/NewsViewModel.dart';
import 'NewsDetail.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _refreshNews() async {
    await context.read<NewsViewModel>().fetchNews(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              _buildSearchBar(context),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<NewsViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading && viewModel.newList.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    return RefreshIndicator(
                      color: const Color(0xFF1A365D),
                      backgroundColor: Colors.white,
                      onRefresh: _refreshNews,
                      child: _buildNewsList(context, viewModel),
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

  Widget _buildNewsList(BuildContext context, NewsViewModel viewModel) {
    if (viewModel.errorMessage.isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Center(
              child: Text(
                viewModel.errorMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    if (viewModel.newList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: const Center(
              child: Text(
                'No hay noticias disponibles en este momento.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
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
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (texto) {
          context.read<NewsViewModel>().onSearchQueryChanged(texto);
        },
        decoration: InputDecoration(
          hintText: 'Buscar noticia...',
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: Colors.black54),
            onPressed: () {
              _searchController.clear();
              context.read<NewsViewModel>().onSearchQueryChanged('');
              FocusScope.of(context).unfocus();
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
                child: const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
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
