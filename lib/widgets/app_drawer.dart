import 'package:flutter/material.dart';
import 'package:zundatalk/models/talk_room.dart';
import 'package:zundatalk/widgets/app_drawer_list_tile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/talk_page.dart';
import '../pages/login_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const TalkPage(),
                ),
              );
            },
            title: const Text('あたらしいるーむをつくるのだ！'),
          ),
          Expanded(
            child: StreamBuilder(
              stream: getRoomStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('えらーがおきたのだ！');
                }

                final rooms = snapshot.data ?? [];
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [for (final room in rooms) AppDrawerListTile(room: room)],
                );
              },
            ),
          ),
          // logout button
          ListTile(
            title: TextButton(
              onPressed: () async {
                final result = await _logout(context);
                if (result && context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  // Messageストリームを取得する
  Stream<List<TalkRoom>> getRoomStream() {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    return Supabase.instance.client
        .from('talk_rooms')
        .stream(primaryKey: ['room_id'])
        .eq('user_id', userId)
        .order(
          'created_at',
        )
        .map((snapshot) {
          return snapshot.map(TalkRoom.fromJson).toList();
        });
  }
}