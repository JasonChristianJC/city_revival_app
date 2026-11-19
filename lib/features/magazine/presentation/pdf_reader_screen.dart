import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/share_helper.dart';
import '../data/magazine_download_service.dart';
import '../data/magazine_repository.dart';
import '../domain/magazine.dart';

class PdfReaderScreen extends ConsumerStatefulWidget {
  final Magazine magazine;

  const PdfReaderScreen({super.key, required this.magazine});

  @override
  ConsumerState<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends ConsumerState<PdfReaderScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _errorMessage;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final downloadService = ref.read(magazineDownloadServiceProvider);

    try {
      // Check if already downloaded
      final existingPath = await downloadService.getLocalPath(widget.magazine.id);
      if (existingPath != null && File(existingPath).existsSync()) {
        setState(() {
          _localPath = existingPath;
          _isLoading = false;
        });
        return;
      }

      // If not yet downloaded, download to read
      final path = await downloadService.downloadMagazine(
        widget.magazine,
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _downloadProgress = p;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _localPath = path;
          _isLoading = false;
        });
        // Invalidate magazines to update offline badges
        ref.invalidate(magazinesProvider);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Could not load PDF directly. You can read it directly via your browser or Google Drive.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.magazine.pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.magazine.issuePeriod),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in Browser',
            onPressed: _openExternal,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Magazine',
            onPressed: () {
              ShareHelper.shareGeneral(
                message:
                    'Paripoorana Jeevan Magazine (${widget.magazine.issuePeriod} ${widget.magazine.year})\nRead here: ${widget.magazine.pdfUrl}',
                subject: widget.magazine.title,
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.divineGold),
              const SizedBox(height: 18),
              Text(
                'Opening Paripoorana Jeevan...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              if (_downloadProgress > 0)
                LinearProgressIndicator(
                  value: _downloadProgress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.divineGold),
                ),
              const SizedBox(height: 8),
              Text(
                _downloadProgress > 0
                    ? '${(_downloadProgress * 100).toInt()}% prepared for offline reading'
                    : 'Loading pages...',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || _localPath == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, size: 64, color: AppColors.primaryWine),
              const SizedBox(height: 16),
              Text(
                widget.magazine.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _openExternal,
                icon: const Icon(Icons.launch),
                label: const Text('Open in Google Drive / Browser'),
              ),
            ],
          ),
        ),
      );
    }

    return PDFView(
      filePath: _localPath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      defaultPage: _currentPage,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        setState(() {
          _totalPages = pages ?? 0;
        });
      },
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = page ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = error.toString();
        });
      },
    );
  }
}
