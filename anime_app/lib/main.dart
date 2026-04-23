import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

const String baseUrl = "https://anime-api-sigma-inky.vercel.app/api/animes";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

// ================= LOGIN PAGE =================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future login() async {
    setState(() {
      loading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3333/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
    );

    final data = jsonDecode(response.body);

    setState(() {
      loading = false;
    });

    if (response.statusCode == 200 && data['status'] == 'ok') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AnimeListPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Anime Login",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= LIST PAGE =================
class AnimeListPage extends StatefulWidget {
  const AnimeListPage({super.key});

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  List animes = [];

  @override
  void initState() {
    super.initState();
    fetchAnimes();
  }

  Future fetchAnimes() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      setState(() {
        animes = jsonDecode(res.body);
      });
    } catch (e) {
      debugPrint("获取数据失败: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anime List"),
        // ✨ 这里是新加入的 Logout 按钮
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 彻底退出：跳转并移除之前所有的页面栈
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false, // 这会让之前的页面全部失效
              );
            },
          ),
        ],
      ),
      body: animes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: animes.length,
              itemBuilder: (context, index) {
                final anime = animes[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        anime['image_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    title: Text(anime['title']),
                    subtitle: Text(
                      "⭐ ${(anime['rating'] as num).toDouble().toStringAsFixed(1)}",
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(anime: anime),
                        ),
                      );
                      fetchAnimes(); // 从详情页返回后自动刷新列表
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ================= DETAIL PAGE =================
class DetailPage extends StatelessWidget {
  final Map anime;

  const DetailPage({super.key, required this.anime});

  Future updateRating(int id, double newRating) async {
    await http.patch(
      Uri.parse("$baseUrl/$id/rating"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rating': newRating}),
    );
  }

  @override
  Widget build(BuildContext context) {
    double current = (anime['rating'] as num).toDouble();

    return Scaffold(
      appBar: AppBar(title: Text(anime['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                anime['image_url'],
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 100);
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(anime['title'], style: const TextStyle(fontSize: 20)),
            Text(anime['description']),
            const SizedBox(height: 10),
            Text(
              "⭐ ${current.toStringAsFixed(1)}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            // 🔥 +1 / -1 buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    double newRating = (current - 1).clamp(0, 5);
                    await updateRating(anime['id'], newRating);
                    Navigator.pop(context);
                  },
                  child: const Text("-1 ⭐"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    double newRating = (current + 1).clamp(0, 5);
                    await updateRating(anime['id'], newRating);
                    Navigator.pop(context);
                  },
                  child: const Text("+1 ⭐"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
