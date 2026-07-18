import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_content_models.dart';
import '../../providers/admin_content_providers.dart';

class ManageNewsPage extends ConsumerWidget {
  final VoidCallback onBack;
  const ManageNewsPage({super.key, required this.onBack});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    NewsArticle? article,
  ]) async {
    final result = await showDialog<NewsArticle>(
      context: context,
      builder: (_) => _NewsDialog(article: article),
    );
    if (result == null) return;
    final error = await ref
        .read(adminContentActionProvider.notifier)
        .saveNews(result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Đã lưu tin tức.'),
        backgroundColor: error == null ? const Color(0xFF16A34A) : null,
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    NewsArticle article,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tin tức?'),
        content: Text(article.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(adminContentActionProvider.notifier).deleteNews(article.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(newsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Quản lý tin tức'),
      ),
      body: news.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Không thể tải tin: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Chưa có tin tức.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final article = items[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _edit(context, ref, article),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: article.published
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              child: Icon(
                                article.published
                                    ? Icons.public
                                    : Icons.drafts_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    article.summary.isEmpty
                                        ? article.content
                                        : article.summary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Xóa',
                              onPressed: () => _delete(context, ref, article),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Thêm tin'),
      ),
    );
  }
}

class _NewsDialog extends StatefulWidget {
  final NewsArticle? article;
  const _NewsDialog({required this.article});

  @override
  State<_NewsDialog> createState() => _NewsDialogState();
}

class _NewsDialogState extends State<_NewsDialog> {
  late final TextEditingController _title;
  late final TextEditingController _summary;
  late final TextEditingController _content;
  late final TextEditingController _image;
  late bool _published;

  @override
  void initState() {
    super.initState();
    final article = widget.article;
    _title = TextEditingController(text: article?.title ?? '');
    _summary = TextEditingController(text: article?.summary ?? '');
    _content = TextEditingController(text: article?.content ?? '');
    _image = TextEditingController(text: article?.imageUrl ?? '');
    _published = article?.published ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _content.dispose();
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.article == null ? 'Thêm tin tức' : 'Sửa tin tức'),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: _summary,
              decoration: const InputDecoration(labelText: 'Tóm tắt'),
              maxLines: 2,
            ),
            TextField(
              controller: _content,
              decoration: const InputDecoration(labelText: 'Nội dung'),
              maxLines: 7,
            ),
            TextField(
              controller: _image,
              decoration: const InputDecoration(labelText: 'URL ảnh'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Xuất bản'),
              value: _published,
              onChanged: (value) => setState(() => _published = value),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          NewsArticle(
            id: widget.article?.id ?? '',
            title: _title.text,
            summary: _summary.text,
            content: _content.text,
            imageUrl: _image.text,
            published: _published,
            createdAt: widget.article?.createdAt ?? DateTime.now(),
          ),
        ),
        child: const Text('Lưu'),
      ),
    ],
  );
}
