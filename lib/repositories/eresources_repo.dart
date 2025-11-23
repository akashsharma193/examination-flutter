import 'dart:developer';
import 'dart:io';
import 'package:crackitx/app_models/eresources_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/remote/app_dio_service.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

class EResourcesRepo {
  final dioService = AppDioService.instance;

  Future<AppResult<Map<String, dynamic>>> getResources({
    int pageNumber = 0,
    int pageSize = 10,
  }) async {
    try {
      final response = await dioService.postDio(
        endpoint: 'ereources/admin/getAll',
        body: {
          "page": {
            "size": pageSize,
            "number": pageNumber,
          }
        },
      );

      log('EResources Response: ${response.toString()}');

      switch (response) {
        case AppSuccess():
          final responseData = response.value;

          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('content')) {
            final content = responseData['content'];
            int totalElements = responseData['totalElements'] ?? 0;
            int totalPages = responseData['totalPages'] ?? 0;
            int currentPageNumber = responseData['number'] ?? 0;
            bool last = responseData['last'] ?? true;

            bool hasNext = !last;
            bool hasPrevious = currentPageNumber > 0;

            log('Parsed content length: ${content?.length ?? 0}');
            log('Total elements: $totalElements');
            log('Total pages: $totalPages');
            log('Current page: $currentPageNumber');

            return AppSuccess({
              'content': content != null
                  ? (content as List<dynamic>)
                      .map((e) => EResourceModel.fromJson(e))
                      .toList()
                  : <EResourceModel>[],
              'totalElements': totalElements,
              'totalPages': totalPages,
              'hasNext': hasNext,
              'hasPrevious': hasPrevious,
            });
          } else {
            return const AppSuccess({
              'content': <EResourceModel>[],
              'totalElements': 0,
              'totalPages': 0,
              'hasNext': false,
              'hasPrevious': false,
            });
          }
        case AppFailure():
          return AppFailure(
            errorMessage: response.errorMessage,
            code: response.code,
          );
      }
    } catch (e) {
      log('Error in getResources: $e');
      return AppResult.failure(const AppFailure());
    }
  }

  String get _baseUrl {
    return AppDioService.dio.options.baseUrl;
  }

  Future<AppResult<String>> downloadResource(String resourceId) async {
    try {
      if (Platform.isAndroid) {
        PermissionStatus status;

        if (Platform.version.contains('Android 13') ||
            Platform.version.contains('Android 14') ||
            Platform.version.contains('Android 15')) {
          status = await Permission.photos.status;

          if (!status.isGranted) {
            status = await Permission.photos.request();

            if (status.isDenied) {
              return const AppFailure(
                errorMessage:
                    'Storage permission is required to download files. Please grant permission.',
              );
            }

            if (status.isPermanentlyDenied) {
              return const AppFailure(
                errorMessage:
                    'Storage permission is permanently denied. Please enable it from Settings.',
              );
            }
          }
        } else {
          status = await Permission.storage.status;

          if (!status.isGranted) {
            status = await Permission.storage.request();

            if (status.isDenied) {
              return const AppFailure(
                errorMessage:
                    'Storage permission is required to download files. Please grant permission.',
              );
            }

            if (status.isPermanentlyDenied) {
              return const AppFailure(
                errorMessage:
                    'Storage permission is permanently denied. Please enable it from Settings.',
              );
            }
          }
        }
      }

      final dio = Dio();
      final token = AppLocalStorage.instance.accessToken;

      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      Directory? directory;
      String fileName = 'resource_$resourceId';

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        return const AppFailure(
          errorMessage: 'Could not access storage directory',
        );
      }

      final filePath = '${directory.path}/$fileName';

      final baseUrl = _baseUrl;
      final downloadUrl = '$baseUrl/ereources/download/$resourceId';

      log('Downloading from: $downloadUrl');
      log('Saving to: $filePath');

      await dio.download(
        downloadUrl,
        filePath,
        options: Options(
          headers: dio.options.headers,
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            log('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      log('File downloaded successfully to: $filePath');
      return AppSuccess(filePath);
    } catch (e) {
      log('Error downloading resource: $e');
      return AppResult.failure(AppFailure(
        errorMessage: 'Failed to download file: ${e.toString()}',
      ));
    }
  }
}
