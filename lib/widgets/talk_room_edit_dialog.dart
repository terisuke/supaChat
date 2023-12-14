import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/talk_room.dart';

class TalkRoomEditDialog extends StatefulWidget {
  const TalkRoomEditDialog({
    super.key,
    required this.room,
  });

  final TalkRoom room;

  @override
  State<TalkRoomEditDialog> createState() => _TalkRoomEditDialogState();
}

class _TalkRoomEditDialogState extends State<TalkRoomEditDialog> {
  late TextEditingController _controller;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.room.name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Talk Room'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Talk Room Name',
            ),
          ),
          if (errorMessage.isNotEmpty)
            Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final result = await updateTalkRoom(
              roomId: widget.room.id!,
              newName: _controller.text,
            );
            if (context.mounted && result != null) Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<TalkRoom?> updateTalkRoom({
    required String roomId,
    required String newName,
  }) async {
    try {
      final result = await Supabase.instance.client.from('talk_rooms').update({'room_name': newName}).eq('room_id', roomId).select();
      return TalkRoom.fromJson(result.first);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      return null;
    }
  }
}