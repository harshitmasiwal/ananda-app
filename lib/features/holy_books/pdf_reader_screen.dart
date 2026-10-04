import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/holy_book_model.dart';

class PdfReaderScreen extends StatefulWidget {
  final HolyBookModel book;
  final bool isHindi;

  const PdfReaderScreen({
    super.key,
    required this.book,
    required this.isHindi,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _downloading = false;
  bool _isSavedLocally = false;
  PDFViewController? _pdfController;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check local saved scripture file first
      final docDir = await getApplicationDocumentsDirectory();
      final localSaved = File('${docDir.path}/${widget.book.id}_scripture.pdf');
      if (localSaved.existsSync()) {
        if (mounted) {
          setState(() {
            _localPath = localSaved.path;
            _isSavedLocally = true;
            _isLoading = false;
          });
        }
        return;
      }

      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final extSaved = File('${extDir.path}/${widget.book.id}_scripture.pdf');
        if (extSaved.existsSync()) {
          if (mounted) {
            setState(() {
              _localPath = extSaved.path;
              _isSavedLocally = true;
              _isLoading = false;
            });
          }
          return;
        }
      }

      final file =
          await DefaultCacheManager().getSingleFile(widget.book.pdfUrl);
      if (mounted) {
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveToDownloads() async {
    if (_localPath == null) return;
    setState(() => _downloading = true);
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final docTarget = File('${docDir.path}/${widget.book.id}_scripture.pdf');
      await File(_localPath!).copy(docTarget.path);

      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final target = File('${extDir.path}/${widget.book.id}_scripture.pdf');
        await File(_localPath!).copy(target.path);
      }
      if (mounted) {
        setState(() => _isSavedLocally = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHindi
                  ? 'पवित्र ग्रंथ डिवाइस में सेव हो गया 📥'
                  : 'Holy Book saved to device 📥',
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHindi ? 'डाउनलोड विफल: $e' : 'Save failed: $e',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _deleteFromDevice() async {
    final title = widget.isHindi ? widget.book.titleHi : widget.book.title;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.isHindi ? 'ग्रंथ हटाएं?' : 'Delete Scripture?',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Text(
          widget.isHindi
              ? 'क्या आप "${title.isNotEmpty ? title : 'यह ग्रंथ'}" को डिवाइस से हटाना चाहते हैं?'
              : 'Do you want to delete "$title" from your device storage?',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              widget.isHindi ? 'रद्द करें' : 'Cancel',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(widget.isHindi ? 'हटाएं' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final docDir = await getApplicationDocumentsDirectory();
        final docTarget = File('${docDir.path}/${widget.book.id}_scripture.pdf');
        if (docTarget.existsSync()) await docTarget.delete();

        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final target = File('${extDir.path}/${widget.book.id}_scripture.pdf');
          if (target.existsSync()) await target.delete();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isHindi
                    ? 'पवित्र ग्रंथ डिवाइस स्टोरेज से हटा दिया गया 🗑️'
                    : 'Holy Book deleted from device 🗑️',
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        }
      } catch (_) {}
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.book.pdfUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isHindi ? widget.book.titleHi : widget.book.title;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_totalPages > 0)
              Text(
                widget.isHindi
                    ? 'पृष्ठ $_currentPage / $_totalPages'
                    : 'Page $_currentPage of $_totalPages',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
              ),
          ],
        ),
        actions: [
          if (_isSavedLocally)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white),
              tooltip:
                  widget.isHindi ? 'हटाएं' : 'Delete from device',
              onPressed: _deleteFromDevice,
            )
          else if (_localPath != null)
            IconButton(
              icon: _downloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded, color: Colors.white),
              tooltip: widget.isHindi ? 'सेव करें' : 'Save',
              onPressed: _downloading ? null : _saveToDownloads,
            ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white),
            tooltip: widget.isHindi ? 'ब्राउज़र में खोलें' : 'Open in browser',
            onPressed: _openExternal,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: (_totalPages > 1 && !_isLoading && _errorMessage == null)
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF2E7D32),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isHindi
                  ? 'पवित्र ग्रंथ लोड हो रहा है...'
                  : 'Loading Holy Scripture...',
              style: AppTextStyles.body.copyWith(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null || _localPath == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.red, size: 52),
              const SizedBox(height: 12),
              Text(
                widget.isHindi
                    ? 'ग्रंथ लोड करने में समस्या आई'
                    : 'Unable to load PDF',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? '',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadFile,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(widget.isHindi ? 'पुनः प्रयास करें' : 'Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _openExternal,
                    icon: const Icon(Icons.open_in_browser_rounded),
                    label: Text(widget.isHindi ? 'ब्राउज़र' : 'Browser'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onViewCreated: (controller) {
        _pdfController = controller;
      },
      onRender: (pages) {
        setState(() {
          _totalPages = pages ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = error.toString();
        });
      },
      onPageError: (page, error) {
        setState(() {
          _errorMessage = 'Page $page: $error';
        });
      },
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = (page ?? 0) + 1;
          _totalPages = total ?? _totalPages;
        });
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Color(0xFF2E7D32)),
              onPressed: _currentPage > 1
                  ? () => _pdfController?.setPage(_currentPage - 2)
                  : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_currentPage / $_totalPages',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF2E7D32)),
              onPressed: _currentPage < _totalPages
                  ? () => _pdfController?.setPage(_currentPage)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
