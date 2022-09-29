import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';

class ContactCard extends StatelessWidget {
  final String name;
  final String profilePicture;
  final String? email;
  final String? phone;
  final DateTime birthday;
  final VoidCallback onTap;

  const ContactCard(
      {required this.name,
      this.email,
      this.phone,
      required this.birthday,
      required this.profilePicture,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(profilePicture),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
                SizedBox(
                  height: 5,
                ),

                // Contact Birthday
                Row(
                  children: [
                    Icon(FontAwesomeIcons.cakeCandles,
                        size: 12, color: Colors.grey.shade500),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      '${DateFormat('d MMM yyyy').format(birthday)}',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Button(
              text: 'Voir',
              height: 40,
              width: 70,
              fontsize: 16,
              fontColor: Colors.black,
              color: Colors.white,
              isBordered: true,
              onTap: onTap)
        ],
      ),
    );
  }
}
