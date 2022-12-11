import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/contact.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/datetimebutton.dart';

class CreateOrUpdateContactPage extends StatefulWidget {
  final Contact? contact;

  CreateOrUpdateContactPage({this.contact});

  @override
  State<CreateOrUpdateContactPage> createState() => _AddContactStatePage();
}

class _AddContactStatePage extends State<CreateOrUpdateContactPage> {
  TextEditingController contactNameController = TextEditingController();
  TextEditingController contactPhoneController = TextEditingController();
  TextEditingController contactEmailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contactNameController.text = widget.contact == null ? '' : widget.contact!.name;
    contactPhoneController.text = widget.contact == null ? '' : widget.contact!.phone;
    contactEmailController.text = widget.contact == null ? '' : widget.contact!.email;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    contactNameController.dispose();
    contactPhoneController.dispose();
    contactEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        heroTag: 'createOrUpdateContactPageAppBar',
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 0.06.sw,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: Text(
          widget.contact == null ? 'Créer un contact' : 'Modifier un contact',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed))
                    return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                  return null; // Use the component's default.
                },
              ),
            ),
            onPressed: () {
              // Import from Contacts (NATIVE)
              debugPrint('Import from Contacts selected !');
            },
            child: Text(
              'Importer',
              style: TextStyle(fontSize: 19),
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // FIELDS
          Expanded(
            child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Contact Avatar
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        // Pick an avatar picture
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage(widget.contact == null
                                ? 'assets/images/picture 3.jpg'
                                : '${widget.contact!.profilePicture}'),
                          ),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: kSecondColor,
                            child: Icon(
                              FontAwesomeIcons.plus,
                              size: 18,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),

                    // Contact Name
                    SizedBox(height: 20),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Expanded(
                        child: TextField(
                          controller: contactNameController,
                          onChanged: (text) {},
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          minLines: 1,
                          // maxLength: 50,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ajouter un nom',
                            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                          ),
                        ),
                      ),
                    ),

                    // Contact Phone
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Expanded(
                        child: TextField(
                          controller: contactPhoneController,
                          onChanged: (text) {},
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          minLines: 1,
                          // maxLength: 50,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ajouter un numéro',
                            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                          ),
                        ),
                      ),
                    ),

                    // Contact Email
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Expanded(
                        child: TextField(
                          controller: contactEmailController,
                          onChanged: (text) {},
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          minLines: 1,
                          // maxLength: 50,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ajouter un email',
                            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(13),
                      child: Divider(
                        color: Colors.grey.shade700,
                        height: 1.7,
                      ),
                    ),

                    // Contact Anniv
                    SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(FontAwesomeIcons.cakeCandles),
                      title: Text(
                        'Ajouter une date d\'anniversaire',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 18, 30, 20),
                        child: DateTimeButton(
                          date: widget.contact == null ? DateTime(2000, 1, 1) : widget.contact!.birthday,
                          type: 'date',
                          onTap: () {
                            debugPrint('Pick start date');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // CREATE or UPDATE Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button(
                    text: widget.contact == null ? 'Créer' : 'Modifier',
                    color: kSecondColor,
                    onTap: () {
                      // Create Contact here !
                      if (widget.contact == null) {
                        // Create New Contact
                        // TO DO
                        debugPrint('Contact Created !');
                      } else if (widget.contact != null) {
                        // Update an existing Contact
                        // TO DO
                        debugPrint('Contact Updated !');
                      }

                      // Pop the Screen once contact created or updated
                      Navigator.pop(context);
                    },
                    height: 40,
                    width: 130,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
