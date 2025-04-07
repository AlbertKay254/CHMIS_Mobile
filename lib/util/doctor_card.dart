import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {

  final String doctorImagePath;
  final String rating;
  final String doctorName;
  final String profession;

  DoctorCard({
    required this.doctorImagePath,
    required this.rating,
    required this.doctorName,
    required this.profession
  });


  @override
  Widget build(BuildContext context) {
    return 
     Padding(
       padding: const EdgeInsets.only(left: 25.0),
       child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
           color: const Color.fromARGB(255, 113, 216, 218),
          ),
          child: Column(children:[
            //picture ->
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                doctorImagePath,
                height: 100,
              ),
            ),
            const SizedBox(height: 10),
            //rating ->
            Row(
              children: [
                Icon(
                  Icons.star,
                  color:Colors.yellow[700],
                ),
                Text(
                  rating,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            //name ->
            Text(
             doctorName,
              style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
            ),
            //title ->
            Text(profession)
          ]),
        ),
     );
  }
}