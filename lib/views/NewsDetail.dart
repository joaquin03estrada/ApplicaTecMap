import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetail extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String content;

  const NewsDetail({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.content,
  });

  // Busca si existe un PDF incrustado dentro de un iframe (visor dinámico)
  String? _extractEmbeddedPdfUrl(String html) {
    final RegExp iframeRegex = RegExp(
      r'<iframe[^>]+src="([^"]+)"',
      caseSensitive: false,
    );
    final match = iframeRegex.firstMatch(html);

    if (match != null) {
      final String srcAttribute = match.group(1)!;
      // Extrae la URL real del PDF dentro del link del visor de Google
      final RegExp pdfRegex = RegExp(
        r'(https?://[^\s"<>&#]+?\.pdf)',
        caseSensitive: false,
      );
      final pdfMatch = pdfRegex.firstMatch(srcAttribute);
      return pdfMatch?.group(0);
    }
    return null;
  }

  Future<void> _openUrl(String? url) async {
    if (url == null) return;
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error al abrir el enlace: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detecta si esta noticia en particular tiene un visor de PDF dinámico oculto
    final String? embeddedPdfUrl = _extractEmbeddedPdfUrl(content);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalle de Noticia'),
        backgroundColor: const Color(0xFF1A365D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Html(
                    data: content,
                    onLinkTap: (url, attributes, element) {
                      _openUrl(url);
                    },
                    style: {
                      "body": Style(
                        fontSize: FontSize(16.0),
                        color: Colors.black87,
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      "p": Style(
                        lineHeight: LineHeight(1.5),
                        textAlign: TextAlign.justify,
                      ),
                      "li": Style(
                        lineHeight: LineHeight(1.5),
                        margin: Margins.only(bottom: 8.0),
                      ),
                      "a": Style(
                        color: Colors.blue[800],
                        textDecoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    },
                  ),

                  // El botón SOLO aparecerá si la noticia originalmente contenía un visor dinámico
                  if (embeddedPdfUrl != null) ...[
                    const SizedBox(height: 24),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openUrl(embeddedPdfUrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A365D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.redAccent,
                      ),
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Descargar Documento de la Noticia',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.download, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
