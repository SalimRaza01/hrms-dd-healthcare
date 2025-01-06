import 'package:flutter/services.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hrms/presentation/screens/view_document.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});
  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
            color: Colors.white,
          ),
        ),
        title: Text(
          'DOCUMENTS',
          style: TextStyle(color: Colors.white),
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
              InkWell(
                    onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewDocument(documentType: 'Private')));
                },
                child: Card(
                  color: Colors.white,
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
                      children: [
                        Image.asset(
                          'assets/image/document2.png',
                          height: height * 0.04,
                        ),
                        SizedBox(
                          width: width * 0.05,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Private',
                              style: TextStyle(
                                  fontSize: height * 0.017,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.mainTextColor),
                            ),
                            SizedBox(
                              width: width / 1.4,
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                'it contains your private document like offer letter, appraisal letter, etc',
                                style: TextStyle(
                                    fontSize: height * 0.013,
                                    color: AppColor.mainTextColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewDocument(documentType: 'Public')));
                },
                child: Card(
                  color: Colors.white,
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
                      children: [
                        Image.asset(
                          'assets/image/document2.png',
                          height: height * 0.04,
                        ),
                        SizedBox(
                          width: width * 0.05,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Public',
                              style: TextStyle(
                                  fontSize: height * 0.017,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.mainTextColor),
                            ),
                            SizedBox(
                              width: width / 1.4,
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                             'it contains public document like holiday list, etc',
                                style: TextStyle(
                                    fontSize: height * 0.013,
                                    color: AppColor.mainTextColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
