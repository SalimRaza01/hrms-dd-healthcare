import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/api/api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/model/models.dart';

class ViewDocument extends StatefulWidget {
  final String documentType;
  const ViewDocument({super.key, required this.documentType});

  @override
  State<ViewDocument> createState() => _ViewDocumentState();
}

class _ViewDocumentState extends State<ViewDocument> {
  bool isDownloading = false;
  late Future<List<DocumentListModel>> documentList;

  @override
  void initState() {
    super.initState();
    documentList = fetchDocumentList(widget.documentType);
  }

  Future<void> _downloadDocument(String url, String filename) async {
  try {

    if (Platform.isAndroid) {
      final plugin = DeviceInfoPlugin();
      final android = await plugin.androidInfo;
      final permission = android.version.sdkInt < 33
          ? await Permission.manageExternalStorage.request()
             : PermissionStatus.granted;

      if (!permission.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Storage permission is required to download documents.'),
          backgroundColor: Colors.red,
        ));
        return;
      }
    }

    setState(() => isDownloading = true);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Downloading Document...'),
      backgroundColor: Colors.blue,
    ));

    final dio = Dio();
    final response = await dio.get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    Directory? directory;

    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    final filePath = '${directory!.path}/$filename.pdf';
    final file = File(filePath);
    await file.writeAsBytes(response.data);

    setState(() => isDownloading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Downloaded to $filePath'),
      backgroundColor: Colors.green,
    ));

    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to open the file'),
        backgroundColor: Colors.red,
      ));
    }
  } catch (e) {
    setState(() => isDownloading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Download failed: $e'),
      backgroundColor: Colors.red,
    ));
  }
}


  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.newgredient1,
              const Color.fromARGB(52, 96, 125, 139),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 5, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD8E1E7),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.chevron_left,
                            color: AppColor.mainTextColor,
                            size: height * 0.018,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '${widget.documentType} Documents',
                      style: TextStyle(
                        fontSize: height * 0.018,
                        color: Colors.black,
                      ),
                    ),
                    Opacity(
                      opacity: 0,
                      child: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              Expanded(
                child: FutureBuilder<List<DocumentListModel>>(
                  future: documentList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: AppColor.mainTextColor2,
                          size: height * 0.03,
                        ),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No document records available.',
                          style: TextStyle(
                            color: AppColor.mainTextColor,
                            fontSize: height * 0.017,
                          ),
                        ),
                      );
                    }

                    final items = snapshot.data!;
                    return ListView.separated(
                      itemCount: items.length,
                      padding: EdgeInsets.zero,
                      separatorBuilder: (_, __) => SizedBox(height: height * 0.015),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          color: AppColor.mainFGColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(38),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD8E1E7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.insert_drive_file_rounded,
                                          color: AppColor.mainTextColor,
                                          size: height * 0.016,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: width * 0.05),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.documentName,
                                          style: TextStyle(
                                            fontSize: height * 0.017,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.mainTextColor,
                                          ),
                                        ),
                                        Text(
                                          item.docType,
                                          style: TextStyle(
                                            fontSize: height * 0.013,
                                            color: AppColor.mainTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: isDownloading
                                      ? null
                                      : () => _downloadDocument(item.location, item.documentName),
                                  icon: Icon(Icons.download),
                                  color: AppColor.mainThemeColor,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
}
