import 'package:flutter/material.dart';
import 'NewsDetail.dart';

class News extends StatelessWidget {
  const News({super.key});

  final List<Map<String, String>> _newsData = const [
    {
      'title': 'noticia 1 xd',
      'imageUrl': 'https://picsum.photos/seed/itc1/500/300',
    },
    {
      'title': 'noticia 2 xd',
      'imageUrl': 'https://picsum.photos/seed/itc2/500/300',
    },
  ];

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
                child: ListView.builder(
                  itemCount: _newsData.length,
                  itemBuilder: (context, index) {
                    final newsItem = _newsData[index];
                    return _buildNewsCard(
                      context: context,
                      title: newsItem['title']!,
                      imageUrl: newsItem['imageUrl']!,
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

  Widget _buildNewsCard({required BuildContext context, required String title, required String imageUrl}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetail(
              title: title,
              imageUrl: imageUrl,
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