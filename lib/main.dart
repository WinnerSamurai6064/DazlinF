import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Global session state
String? globalUsername;
String? globalToken;

void main() {
  runApp(const DazLinApp());
}

class DazLinApp extends StatelessWidget {
  const DazLinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daz-Lin',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19), 
        primaryColor: const Color(0xFF84CC16), 
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF84CC16),
          surface: Color(0xFF111827), 
        ),
        fontFamily: 'Inter',
      ),
      home: const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ================= AUTHENTICATION SCREEN =================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final String apiUrl = 'https://flat-waterfall-d7d4.tekbizz.workers.dev/api/auth';
  bool isLoading = false;

  Future<void> _submitAuth() async {
    setState(() => isLoading = true);
    final endpoint = isLogin ? '$apiUrl/login' : '$apiUrl/register';
    
    Map<String, dynamic> body = {
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text,
    };
    if (!isLogin) body['username'] = _usernameCtrl.text.trim();

    try {
      final res = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      final data = jsonDecode(res.body);
      
      if (data['success'] == true) {
        globalUsername = data['username'];
        globalToken = data['token'];
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      } else {
        _showError(data['error'] ?? "Authentication failed");
      }
    } catch (e) {
      _showError("Network error. Check connection.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Daz-Lin', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(isLogin ? 'Welcome back' : 'Create an account', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              
              if (!isLogin)
                TextField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(hintText: 'Username', filled: true, fillColor: const Color(0xFF111827), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
              if (!isLogin) const SizedBox(height: 16),
              
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(hintText: 'Email address', filled: true, fillColor: const Color(0xFF111827), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(hintText: 'Password', filled: true, fillColor: const Color(0xFF111827), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF84CC16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: isLoading ? null : _submitAuth,
                  child: isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black)) 
                      : Text(isLogin ? 'SIGN IN' : 'SIGN UP', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Log In", style: const TextStyle(color: Colors.grey)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ================= MAIN LAYOUT =================
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const ChatListScreen(),
    const Center(child: Text("Updates")),
    const Center(child: Text("Community")),
    const SettingsScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF111827),
        selectedItemColor: const Color(0xFF84CC16),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Updates'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// ================= SETTINGS SCREEN =================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF0B0F19)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFF84CC16), child: Icon(Icons.person, color: Colors.black)),
            title: Text(globalUsername ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: const Text("Available"),
          ),
          const Divider(color: Color(0xFF1F2937), height: 40),
          _buildSettingsTile(Icons.star_border, "Starred"),
          _buildSettingsTile(Icons.history, "Chat history"),
          const SizedBox(height: 20),
          _buildSettingsTile(Icons.key, "Account"),
          _buildSettingsTile(Icons.lock_outline, "Privacy"),
          _buildSettingsTile(Icons.chat_outlined, "Chats"),
          _buildSettingsTile(Icons.notifications_none, "Notifications"),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}

// ================= CHAT LIST SCREEN =================
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        title: const Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.camera_alt_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.edit_square), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildStoryBubble("Add", true),
                _buildStoryBubble("Julianna", false),
                _buildStoryBubble("VG Parago", false),
                _buildStoryBubble("Coffee", false),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1F2937)),
          Expanded(
            child: ListView(
              children: [
                _buildChatTile(context, "Global Chat Room", "Tap to join everyone", "Live", true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF84CC16),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {},
      ),
    );
  }

  Widget _buildStoryBubble(String name, bool isAdd) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isAdd ? Colors.grey : const Color(0xFF84CC16), width: 2),
            ),
            child: Icon(isAdd ? Icons.add : Icons.person, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, String name, String msg, String time, bool unread) {
    return ListTile(
      leading: const CircleAvatar(backgroundColor: Color(0xFF111827), radius: 24, child: Icon(Icons.groups, color: Color(0xFF84CC16))),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(msg, style: TextStyle(color: unread ? Colors.white : Colors.grey)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: TextStyle(color: unread ? const Color(0xFF84CC16) : Colors.grey, fontSize: 12)),
          if (unread)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFF84CC16), shape: BoxShape.circle),
              child: const Text("1", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
            )
        ],
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatThreadScreen())),
    );
  }
}

// ================= CHAT THREAD SCREEN =================
class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  List<dynamic> _messages = [];
  Timer? _timer;
  final String apiUrl = 'https://flat-waterfall-d7d4.tekbizz.workers.dev/api/chat';

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) => _fetchMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        if (mounted) setState(() => _messages = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    try {
      await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sender_name': globalUsername ?? 'Unknown', 'content': text}),
      );
      _fetchMessages();
    } catch (e) {
      debugPrint("Send error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Row(
          children: [
            CircleAvatar(backgroundColor: Color(0xFF0B0F19), child: Icon(Icons.groups, color: Color(0xFF84CC16), size: 20)),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Global Chat', style: TextStyle(fontSize: 16)),
                Text('online', style: TextStyle(fontSize: 12, color: Color(0xFF84CC16))),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['sender_name'] == globalUsername;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF84CC16) : const Color(0xFF111827),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe) Text(msg['sender_name'], style: const TextStyle(color: Color(0xFF84CC16), fontSize: 12, fontWeight: FontWeight.bold)),
                        if (!isMe) const SizedBox(height: 4),
                        Text(msg['content'], style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 15)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF111827),
            child: Row(
              children: [
                const Icon(Icons.add, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF0B0F19),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                  onPressed: () {},
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFF84CC16),
                    radius: 20,
                    child: Icon(Icons.mic, color: Colors.black, size: 20), 
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
