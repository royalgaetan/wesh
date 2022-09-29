import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wesh/models/contact.dart';
import 'package:wesh/pages/in.pages/create_or_update_contactpage.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';

class ContactView extends StatelessWidget {
  final Contact contact;

  const ContactView({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Contact Avatar
        CircleAvatar(
          radius: 70,
          backgroundImage: AssetImage(contact.profilePicture),
        ),

        // Contact Name
        SizedBox(height: 20),
        Text(
          '${contact.name}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        // Edit Contact Button
        SizedBox(height: 20),
        Button(
          text: 'Modifier',
          height: 40,
          width: 150,
          fontsize: 16,
          fontColor: Colors.black,
          color: Colors.white,
          isBordered: true,
          prefixIcon: Icons.edit,
          prefixIconColor: Colors.black,
          prefixIconSize: 22,
          onTap: () {
            // Edit Contact here !
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => (CreateOrUpdateContactPage(
                  contact: contact,
                )),
              ),
            );
            ;
          },
        ),

        // Contact Birthday
        SizedBox(height: 20),
        ListTile(
          leading: const Icon(FontAwesomeIcons.cakeCandles),
          title: Text(
            DateFormat('d MMM yyyy').format(contact.birthday),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Date d\'anniversaire',
          ),
        ),

        // Contact Phone
        SizedBox(height: 5),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text(
            contact.phone == '' ? 'Aucun numéro de téléphone' : contact.phone,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Téléphone',
          ),
        ),

        // Contact Email
        SizedBox(height: 5),
        ListTile(
          leading: Icon(Icons.mail),
          title: Text(
            contact.email == '' ? 'Aucune adresse email' : contact.email,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Email',
          ),
        ),
      ],
    );
  }
}
