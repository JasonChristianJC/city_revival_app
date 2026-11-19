import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/magazine.dart';

class MagazineDownloadService {
  final Dio _dio = Dio();

  Future<String?> getLocalPath(String magazineId) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('mag_path_$magazineId');
    if (path != null && File(path).existsSync()) {
      return path;
    }
    return null;
  }

  Future<bool> isDownloaded(String magazineId) async {
    final path = await getLocalPath(magazineId);
    return path != null;
  }

  Future<String> downloadMagazine(
    Magazine magazine, {
    void Function(double progress)? onProgress,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final magazinesDir = Directory('${docsDir.path}/magazines');
    if (!magazinesDir.existsSync()) {
      magazinesDir.createSync(recursive: true);
    }

    final sanitizedTitle = magazine.title.replaceAll(RegExp(r'[^\w\s]+'), '_');
    final filePath = '${magazinesDir.path}/${magazine.id}_$sanitizedTitle.pdf';

    final targetFile = File(filePath);
    if (targetFile.existsSync()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mag_path_${magazine.id}', filePath);
      return filePath;
    }

    final downloadUrl = magazine.directDownloadUrl;

    await _dio.download(
      downloadUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mag_path_${magazine.id}', filePath);

    return filePath;
  }

  Future<void> deleteDownload(String magazineId) async {
    final path = await getLocalPath(magazineId);
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mag_path_$magazineId');
    }
  }
}
