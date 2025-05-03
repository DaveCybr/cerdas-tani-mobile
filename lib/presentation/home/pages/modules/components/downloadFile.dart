import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<void> downloadFile(
    BuildContext context, String url, String filename) async {
  int sdkInt = await _getAndroidVersion();

  PermissionStatus status;
  if (sdkInt >= 33) {
    status = await Permission.photos.request();
  } else if (sdkInt >= 30) {
    status = await Permission.manageExternalStorage.request();
  } else {
    status = await Permission.storage.request();
  }

  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Izin ditolak. Harap aktifkan di pengaturan.")),
    );
    openAppSettings();
    return;
  }

  try {
    Directory dir = Directory('/storage/emulated/0/Download');
    String savePath = "${dir.path}/$filename";

    await Dio().download(url, savePath);
    print("Download selesai: $savePath");

    // ✅ Tampilkan SnackBar berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("File berhasil diunduh ke folder Download."),
      ),
    );
  } catch (e) {
    print("Gagal download: $e");

    // ❌ Tampilkan SnackBar error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal mengunduh file.")),
    );
  }
}

Future<int> _getAndroidVersion() async {
  final info = await DeviceInfoPlugin().androidInfo;
  return info.version.sdkInt;
}
