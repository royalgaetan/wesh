import 'package:flutter/material.dart';

class SettingCard extends StatefulWidget {
  final Widget leading;
  final String settingTitle;
  final String settingSubTitle;
  final Widget? settingSubTitle2;
  final Widget trailing;
  final Function() onTap;

  const SettingCard({
    super.key,
    required this.onTap,
    required this.trailing,
    required this.settingTitle,
    required this.settingSubTitle,
    this.settingSubTitle2,
    required this.leading,
  });

  @override
  State<SettingCard> createState() => _SettingCardState();
}

class _SettingCardState extends State<SettingCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Leading
                widget.leading,

                const SizedBox(
                  width: 15,
                ),

                // Setting content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.settingTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),

                      // SubTitle
                      widget.settingSubTitle.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                widget.settingSubTitle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 15,
                                    color: Colors.black.withOpacity(0.7)),
                              ),
                            )
                          : Container(),

                      // SubTitle 2 [Widget]
                      widget.settingSubTitle2 != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: widget.settingSubTitle2!,
                            )
                          : Container(),
                    ],
                  ),
                ),

                // Trailing
                const SizedBox(
                  width: 5,
                ),

                widget.trailing
              ],
            ),
          ],
        ),
      ),
    );
  }
}
