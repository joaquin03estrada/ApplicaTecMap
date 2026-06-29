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
                    extensions: [
                      TagExtension(
                        tagsToExtend: {"img"},
                        builder: (extensionContext) {
                          final String? imageUrl =
                              extensionContext.attributes['src'];
                          if (imageUrl == null) return const SizedBox.shrink();

                          // Calculamos el ancho exacto de la pantalla del dispositivo.
                          // Le restamos 32 para compensar el Padding de 16 que le pusiste a los lados de la pantalla.
                          final double screenWidth =
                              MediaQuery.of(context).size.width - 32;

                          return Container(
                            width: screenWidth, // Imponemos el límite estricto
                            margin: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit
                                  .contain, // Encoge la imagen para que quepa en el screenWidth
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    padding: const EdgeInsets.all(16),
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
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
                      // Acorralamos a las etiquetas <figure> de WordPress para que tampoco se expandan
                      "figure": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        width: Width(100, Unit.percent),
                      ),
                      "a": Style(
                        color: Colors.blue[800],
                        textDecoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    },
                  ),

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
                            'Abrir PDF',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
