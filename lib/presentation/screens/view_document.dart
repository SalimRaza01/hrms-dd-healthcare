import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
// import 'package:path_provider/path_provider.dart';
import '../../core/model/models.dart';

class ViewDocument extends StatefulWidget {
  final String documentType;
  const ViewDocument({super.key, required this.documentType});

  @override
  State<ViewDocument> createState() => _ViewDocumentState();
}

class _ViewDocumentState extends State<ViewDocument> {
  late String documentType;
  late Future<List<DocumentListModel>> documentList;

  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    documentList = fetchDocumentList(widget.documentType);
  }

  Future<void> _downloadDocument(String url, String filename) async {
    // Request storage permissions
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Storage permission is required to download the document'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isDownloading = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading Document'),
        backgroundColor: Colors.blue,
      ),
    );

    try {
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final myDownloads = '/storage/emulated/0/Download';
      final filePath = '$myDownloads/$filename.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      setState(() {
        isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Downloaded to $filePath'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      setState(() {
        isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to download the document'),
        backgroundColor: Colors.red,
      ));
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.mainBGColor,
      appBar: AppBar(
        backgroundColor: AppColor.mainThemeColor,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColor.mainFGColor,
          ),
        ),
        title: Text(
          'View Documents',
          style: TextStyle(color: AppColor.mainFGColor),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<DocumentListModel>>(
                  future: documentList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('No document records available.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No document records available.'));
                    } else {
                      List<DocumentListModel> items = snapshot.data!;

                      return ListView.separated(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          DocumentListModel item = items[index];

                          return Card(
                            color: AppColor.mainFGColor,
                            elevation: 4,
                            margin: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadowColor: Colors.black.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/image/document2.png',
                                          height: height * 0.04,
                                        ),
                                        SizedBox(
                                          width: width * 0.05,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.documentName,
                                              style: TextStyle(
                                                  fontSize: height * 0.017,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColor.mainTextColor),
                                            ),
                                            Text(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              item.docType,
                                              style: TextStyle(
                                                  fontSize: height * 0.013,
                                                  color:
                                                      AppColor.mainTextColor),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: isDownloading
                                          ? null
                                          : () {
                                              _downloadDocument(item.location,
                                                  item.documentName);
                                            },
                                      icon: Icon(Icons.download),
                                      color: AppColor.mainThemeColor,
                                      tooltip: 'Download Document',
                                    ),
                                  ]),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: height * 0.01,
                          );
                        },
                      );
                    }
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
