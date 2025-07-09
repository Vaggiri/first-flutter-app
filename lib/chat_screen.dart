import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:app2/models/message.dart';
import 'package:app2/utils/bluetooth_manager.dart';
import 'package:app2/widgets/chat_bubble.dart';
import 'package:app2/widgets/typing_indicator.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatScreen extends StatefulWidget {
  final BluetoothDevice device;

  const ChatScreen({super.key, required this.device});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();
  bool _isTyping = false;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _setupBluetoothListeners();
    _loadInitialMessage();
    _initializeTTS();
  }

  void _initializeTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
  }

  void _setupBluetoothListeners() {
    BluetoothManager.onMessageReceived.listen((message) {
      setState(() {
        _messages.add(Message(
          text: message,
          isMe: false,
          time: DateTime.now(),
        ));
        _scrollToBottom();
      });
      _readMessageAloud(message);
      _vibrateOnMessage();
    });

    widget.device.state.listen((state) {
      if (state == BluetoothDeviceState.disconnected) {
        setState(() => _isConnected = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device disconnected'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _loadInitialMessage() {
    setState(() {
      _messages.add(Message(
        text: 'Connected to ${widget.device.platformName}',
        isMe: false,
        time: DateTime.now(),
        isSystem: true,
      ));
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(Message(
        text: message,
        isMe: true,
        time: DateTime.now(),
      ));
      _scrollToBottom();
    });

    try {
      await BluetoothManager.sendMessage(widget.device, message);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _readMessageAloud(String message) async {
    await _tts.speak(message);
  }

  void _vibrateOnMessage() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.device.platformName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _isConnected ? 'Connected' : 'Disconnected',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            BluetoothManager.disconnectDevice(widget.device);
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Start chatting with ${widget.device.platformName}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        return ChatBubble(
                          message: _messages[index],
                        ).animate().fadeIn(delay: 100.ms);
                      } else {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: TypingIndicator(),
                        );
                      }
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        onPressed: () {
                          // TODO: Add emoji picker
                        },
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _isTyping = text.isNotEmpty;
                      });
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _tts.stop();
    super.dispose();
  }
}