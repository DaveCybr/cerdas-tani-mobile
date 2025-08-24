// presentation/dashboard/articles/screens/article_detail.dart
import 'package:fertilizer_calculator_mobile_v2/core/navigations/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/navigations/app_route.dart';
import '../models/article_model.dart';
import '../providers/article_provider.dart';

class ArticleDetailPage extends StatefulWidget {
  final Article article;

  const ArticleDetailPage({Key? key, required this.article}) : super(key: key);

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Article? _detailArticle;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _loadArticleDetail();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 300) {
      if (!_showFloatingButton) {
        setState(() {
          _showFloatingButton = true;
        });
      }
    } else {
      if (_showFloatingButton) {
        setState(() {
          _showFloatingButton = false;
        });
      }
    }
  }

  void _loadArticleDetail() async {
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<ArticleProvider>(context, listen: false);
    final detailArticle = await provider.fetchArticleById(widget.article.id);

    setState(() {
      _detailArticle = detailArticle ?? widget.article;
      _isLoading = false;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = _detailArticle ?? widget.article;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // App Bar with Image
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.darkText,
                        size: 18,
                      ),
                      onPressed: () => AppNavigator.pop(context),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.share,
                          color: AppColors.darkText,
                          size: 20,
                        ),
                        onPressed: () => _shareArticle(article),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'article-image-${article.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          image:
                              article.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                    image: NetworkImage(article.imageUrl),
                                    fit: BoxFit.cover,
                                    onError: (error, stackTrace) {
                                      // Handle image load error
                                    },
                                  )
                                  : null,
                          color:
                              article.imageUrl.isEmpty
                                  ? AppColors.primaryLight
                                  : null,
                        ),
                        child:
                            article.imageUrl.isEmpty
                                ? Center(
                                  child: Icon(
                                    Icons.article,
                                    size: 64,
                                    color: AppColors.primary,
                                  ),
                                )
                                : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),

                // Article Content
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Article Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category and Read Time
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      article.category,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppColors.lightText,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    article.readTime,
                                    style: TextStyle(
                                      color: AppColors.lightText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Article Title
                              Text(
                                article.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Author and Date
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primaryLight,
                                    child: Text(
                                      article.createdByName.isNotEmpty
                                          ? article.createdByName[0]
                                              .toUpperCase()
                                          : 'A',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article.createdByAlias ??
                                              article.createdByName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkText,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          _formatDate(article.publishedAt),
                                          style: TextStyle(
                                            color: AppColors.lightText,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          height: 1,
                          color: AppColors.outline.withOpacity(0.3),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                        ),

                        // Article Intro
                        if (article.intro.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                article.intro,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.darkText,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),

                        // Article Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child:
                              _isLoading
                                  ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(40),
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                  : _buildArticleContent(article),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Action Button
            if (_showFloatingButton)
              Positioned(
                bottom: 30,
                right: 20,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.primary,
                  onPressed: _scrollToTop,
                  child: Icon(Icons.keyboard_arrow_up, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _generateDummyContent() {
    return """
Dalam dunia pertanian modern, pemilihan dan penggunaan pupuk yang tepat merupakan kunci utama keberhasilan budidaya tanaman. Artikel ini akan membahas secara mendalam tentang berbagai aspek penting dalam pemupukan yang perlu dipahami oleh para petani dan pelaku pertanian.

Pemupukan yang efektif tidak hanya berkaitan dengan jenis pupuk yang digunakan, tetapi juga timing aplikasi, dosis yang tepat, dan metode pemberian yang sesuai dengan kebutuhan tanaman. Setiap fase pertumbuhan tanaman memiliki kebutuhan nutrisi yang berbeda-beda.

Pada fase vegetatif, tanaman membutuhkan nitrogen dalam jumlah yang cukup untuk mendukung pertumbuhan daun dan batang. Sementara itu, pada fase generatif, kebutuhan fosfor dan kalium menjadi lebih dominan untuk mendukung pembentukan bunga dan buah.

Faktor lingkungan seperti pH tanah, kelembaban, dan suhu juga sangat mempengaruhi efektivitas pemupukan. Oleh karena itu, analisis tanah secara berkala sangat direkomendasikan untuk menentukan strategi pemupukan yang optimal.

Selain itu, penggunaan pupuk organik sebagai pelengkap pupuk anorganik dapat meningkatkan struktur tanah dan aktivitas mikroorganisme yang bermanfaat bagi tanaman. Kombinasi yang tepat antara pupuk organik dan anorganik akan memberikan hasil yang maksimal.

Pemahaman yang baik tentang prinsip-prinsip pemupukan ini akan membantu petani mencapai produktivitas yang optimal sambil tetap menjaga kelestarian lingkungan dan keberlanjutan sistem pertanian.
    """;
  }

  Widget _buildArticleContent(Article article) {
    final content =
        article.content.isNotEmpty ? article.content : _generateDummyContent();

    // Check if content contains HTML tags
    if (_containsHtmlTags(content)) {
      return Html(
        data: content,
        style: {
          "body": Style(
            fontSize: FontSize(16),
            color: AppColors.mainText,
            lineHeight: LineHeight(1.8),
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          "p": Style(
            fontSize: FontSize(16),
            color: AppColors.mainText,
            lineHeight: LineHeight(1.8),
            margin: Margins.only(bottom: 16),
          ),
          "strong": Style(
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
          "em": Style(fontStyle: FontStyle.italic, color: AppColors.mainText),
          "h1, h2, h3, h4, h5, h6": Style(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            margin: Margins.only(top: 20, bottom: 10),
          ),
          "ul, ol": Style(
            margin: Margins.only(bottom: 16),
            padding: HtmlPaddings.only(left: 20),
          ),
          "li": Style(margin: Margins.only(bottom: 8)),
          "blockquote": Style(
            backgroundColor: AppColors.primaryLight,
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 4),
            ),
            padding: HtmlPaddings.all(16),
            margin: Margins.only(bottom: 16),
            fontStyle: FontStyle.italic,
          ),
        },
        onLinkTap: (url, _, __) {
          // Handle link taps if needed
          print('Link tapped: $url');
        },
      );
    } else {
      // Display as plain text with proper formatting
      return Text(
        content,
        style: TextStyle(fontSize: 16, color: AppColors.mainText, height: 1.8),
      );
    }
  }

  bool _containsHtmlTags(String content) {
    final htmlRegex = RegExp(r'<[^>]*>');
    return htmlRegex.hasMatch(content);
  }

  void _shareArticle(Article article) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur berbagi akan segera tersedia'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _bookmarkArticle(Article article) {
    // Implement bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Artikel disimpan ke bookmark'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _copyLink(Article article) {
    // Implement copy link functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link artikel disalin'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
