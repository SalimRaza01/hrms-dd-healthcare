import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmerAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColor.mainBGColor,
      body: SingleChildScrollView(
        child:  Shimmer.fromColors(
 
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          enabled: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 100),
            child: Column(children: [
              Container(
                        width: 120,
                        height: height * 0.14,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: width * 0.01,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0, 10),
                            ),
                          ],
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                    
                        ),
                      ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(children: [
                    Container(
               height: height * 0.15,
                      decoration: BoxDecoration(
                               color: AppColor.mainBGColor,
                        border: Border.all(color: AppColor.mainBGColor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    
                    ),
                    SizedBox(
                      height: 15,
                    ),
                     Container(
               height: height * 0.15,
                      decoration: BoxDecoration(
                               color: AppColor.mainBGColor,
                        border: Border.all(color: AppColor.mainBGColor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    
                    ),
                    SizedBox(
                      height: 15,
                    ),
                      Container(
               height: height * 0.15,
                      decoration: BoxDecoration(
                               color: AppColor.mainBGColor,
                        border: Border.all(color: AppColor.mainBGColor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          Icons.square_rounded,
                 
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '      ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColor.mainTextColor,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
