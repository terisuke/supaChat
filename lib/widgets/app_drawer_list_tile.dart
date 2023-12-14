import 'package:flutter/material.dart';
import 'package:zundatalk/widgets/talk_room_edit_dialog.dart';

import '../models/talk_room.dart';
import '../pages/talk_page.dart';

class AppDrawerListTile extends StatelessWidget {
  const AppDrawerListTile({
    super.key,
    required this.room,
  });

  final TalkRoom room;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.comment),
      title: Text(room.name),
      onTap: () {
        // チャットページを差し替える
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TalkPage(room: room),
          ),
        );
      },
      trailing: IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return TalkRoomEditDialog(room: room);
            },
          );
        },
        icon: const Icon(Icons.edit),
      ),
    );
  }
}