import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/colors.dart';


class CompletedTaskCard extends StatelessWidget {
  //final Map wObj;
  const CompletedTaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
        //margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        height: 90,
        //padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Row(
            children: [
              ClipRRect(
                //borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  "assets/images/personal-activity.png",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 15,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chạy 100km quanh hồ, đạp xe 100km, đi bộ 100km",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2,),
                    Text(
                      "Bắt đầu: 15h30 phút ngày 25/02/2025",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ));
  }
}