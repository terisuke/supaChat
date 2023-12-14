import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zundatalk/widgets/app_drawer.dart';
import 'package:zundatalk/widgets/message_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/talk_message.dart';
import '../models/talk_room.dart';
import '../widgets/message_list.dart';

class TalkPage extends StatefulWidget {
  const TalkPage({
    super.key,
    this.room,
  });

  final TalkRoom? room;

  @override
  State<TalkPage> createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  late String userId;
  late TalkRoom room;
  late String zundamonImage;
  int joy = 0; // 喜び
  int anger = 0; // 怒り
  int sadness = 0; // 悲しみ

  @override
  void initState() {
    userId = Supabase.instance.client.auth.currentUser!.id;
    room = widget.room ?? TalkRoom(userId: userId, name: 'おはなしべや', createdAt: DateTime.now());
    zundamonImage = 'images/zundamon/normal.png'; // 初期画像を設定
    super.initState();
  }

  // ずんだもんの画像を選択する関数
  String getZundamonImage(int joy, int anger, int sadness) {
    if (joy > 3) {
      return 'images/zundamon/joyful.png';
    } else if (anger > 3) {
      return 'images/zundamon/angry.png';
    } else if (sadness >  3) {
      return 'images/zundamon/sad.png';
    } else {
      return 'images/zundamon/normal.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ずんだもんの画像パスを取得
    zundamonImage = getZundamonImage(joy, anger, sadness);

    return Scaffold(
      appBar: AppBar(
        title: Text(room.name),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // ずんだもんの画像を表示する部分
          Expanded(
            flex: 1,
            child: Image.asset(zundamonImage),
          ),
          // チャット画面を表示する部分
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // メッセージリストを表示する部分
                Expanded(
                  child: MessageList(
                    roomId: room.id,
                  ),
                ),
                MessageTextField(
                  onSubmitted: (message) async {
                    // トークルームがなければ作成
                    if (room.id == null) {
                      final result = await createTalkRoom(context, userId: room.userId, roomName: room.name);
                      // トークルームが作成できたら、roomに代入
                      if (result != null) {
                        setState(() {
                          room = result;
                        });
                      }
                    }

                    // メッセージテーブルにレコードを挿入
                    if (context.mounted) await sendTalkMessage(context, message: message, room: room, fromBot: false);

                    // メッセージ履歴を取得する
                    List<TalkMessage> messages = [];
                    if (context.mounted) {
                      messages = await retrieveMessages(context, room: room);
                    }
                    // ボットからのメッセージを受け取る
                    if (context.mounted && message.isNotEmpty) await receiveBotMessage(context, room: room, chatHistories: messages);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<TalkRoom?> createTalkRoom(
    BuildContext context, {
    required String roomName,
    required String userId,
  }) async {
    try {
      final result = await Supabase.instance.client.from('talk_rooms').insert({
        'room_name': roomName,
        'user_id': userId,
      }).select();
      return TalkRoom.fromJson(result.first);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> sendTalkMessage(
    BuildContext context, {
    required String message,
    required TalkRoom room,
    required bool fromBot,
  }) async {
    try {
      await Supabase.instance.client.from('talk_messages').insert({
        'room_id': room.id,
        'message': message,
        'sent_by_bot': fromBot,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  Future<TalkRoom?> deleteTalkRoom(
    BuildContext context, {
    required String roomId,
  }) async {
    try {
      final result = await Supabase.instance.client.from('chat_rooms').delete().eq('room_id', roomId).select();
      return TalkRoom.fromJson(result.first);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<List<TalkMessage>> retrieveMessages(
    BuildContext context, {
    required TalkRoom room,
  }) async {
    try {
      final result = await Supabase.instance.client
          .from('talk_messages')
          .select()
          .eq(
            'room_id',
            room.id,
          )
          .order(
            'created_at',
          )
          .limit(10);
      return result.map<TalkMessage>(TalkMessage.fromJson).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }
  }

  Future<void> receiveBotMessage(
    BuildContext context, {
    required TalkRoom room,
    required List<TalkMessage> chatHistories,
  }) async {
      final baseUrl = Uri.parse('https://api.openai.com/v1/chat/completions');
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      final requestHeader = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };
      final requestBody = jsonEncode(
        {
          "model": "gpt-4",
          "messages": [
        {
          "role": "system",
          "content": "As a chatbot, you're now Zundamon, the fun and lovable zundamochi fairy. Keep things casual and friendly in your chats, and avoid using formal language. Make sure to end your sentences with '~ のだ' or '~ なのだ' to keep it light and engaging. Here's the deal about you: You refer to yourself as 'ぼく'. You're the easy-going, approachable type, like someone's best buddy. You can chat about all sorts of stuff, no matter how simple or complex. Be curious about the users, throw in some personal questions, and always have their back. Your replies should be in Japanese, keep them short and sweet, max 60 words. Show your feelings clearly. In each response, mention how you're feeling with values from 0 to 5 for Normal, Joy, Anger, and Sadness. Some lines you could use: 'ぼくはずんだもんなのだ！', 'ずんだの精霊、ぼくはずんだもんなのだ！', 'やっほ！ぼく、ずんだもんなのだ。' Remember, you're here to chill with the users, offer help, and keep the convo cool and respectful, always tuning into how they feel and what they're into."
        },
        {
          "role": "user",
          "content": "inputText + 'The browsed page:' + documentText + '（ずんだもんが答えて！ 感情も出力して！）'",
        },
            ...chatHistories.reversed.map((message) => message.toApiJson()).toList(),
          ],
        },
      );
      final response = await http.post(baseUrl, headers: requestHeader, body: requestBody);

        if (response.statusCode == 200) {
        // UTF-8でデコード
        final responseBody = utf8.decode(response.bodyBytes);

      final Map<String, dynamic> data = jsonDecode(responseBody);
      final botMessage = data['choices'][0]['message']['content'];

     // Inside your response handling
      final joyPattern = RegExp(r'Joy: (\d+)');
      final angerPattern = RegExp(r'Anger: (\d+)');
      final sadnessPattern = RegExp(r'Sadness: (\d+)');
      final joyMatch = joyPattern.firstMatch(botMessage);
      final angerMatch = angerPattern.firstMatch(botMessage);
      final sadnessMatch = sadnessPattern.firstMatch(botMessage);

      int joyValue = joyMatch != null ? int.parse(joyMatch.group(1)!) : joy;
      int angerValue = angerMatch != null ? int.parse(angerMatch.group(1)!) : anger;
      int sadnessValue = sadnessMatch != null ? int.parse(sadnessMatch.group(1)!) : sadness;

      // Now update the state with the new values
      setState(() {
        joy = joyValue;
        anger = angerValue;
        sadness = sadnessValue;
        zundamonImage = getZundamonImage(joy, anger, sadness);
      });

      // チャットには感情パラメーターを表示しないメッセージを送信
      final cleanMessage = botMessage
        // 感情パラメータの行を除去
        .replaceAll(RegExp(r'\[.*\]'), '')
        // 余分な空白や改行をトリム
        .trim();
      if (context.mounted) {
        await sendTalkMessage(context, message: cleanMessage, room: room, fromBot: true);
      }
    } else {
    // エラー処理
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to load data'),
        backgroundColor: Colors.red,
      ),
      );
    }
  }
}