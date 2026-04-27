import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

// ================= API 配置 =================
const String domain = "https://anime-api-jjsm.vercel.app";
const String baseUrl = "$domain/api/animes";
const String loginUrl = "$domain/api/login";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anime Cloud App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const LoginPage(),
    );
  }
}

// ================= 登录页面 =================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    if (userCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      showError("Please enter username and password");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': userCtrl.text,
          'password': passCtrl.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AnimeListPage(username: userCtrl.text),
          ),
        );
      } else {
        showError(data['message'] ?? "Login Failed");
      }
    } catch (e) {
      showError("Connection Error: Check if API is online.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anime Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.cloud_done, size: 100, color: Colors.indigo),
            const SizedBox(height: 30),
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 动漫列表 =================
class AnimeListPage extends StatefulWidget {
  final String username;

  const AnimeListPage({super.key, required this.username});

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  List animes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAnimes();
  }

  Future<void> loadAnimes() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));

      if (res.statusCode == 200) {
        setState(() {
          animes = jsonDecode(res.body);
          loading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> updateRating(int id, double rating) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/$id/rating"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rating': rating}),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE: ${response.body}");
    } catch (e) {
      print("PATCH ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Anime List"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadAnimes,
              child: ListView.builder(
                itemCount: animes.length,
                itemBuilder: (context, i) {
                  final item = animes[i];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      leading: Image.network(
                        item['image_url'] ?? '',
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                      title: Text(item['title'] ?? 'No Title'),
                      subtitle: Text("Rating: ⭐ ${item['rating']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              double r =
                                  double.tryParse(item['rating'].toString()) ??
                                  0.0;

                              double newRating = double.parse(
                                (r - 0.1).toStringAsFixed(1),
                              );

                              setState(() {
                                item['rating'] = newRating;
                              });

                              await updateRating(item['id'], newRating);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.green,
                            ),
                            onPressed: () async {
                              double r =
                                  double.tryParse(item['rating'].toString()) ??
                                  0.0;

                              double newRating = double.parse(
                                (r + 0.1).toStringAsFixed(1),
                              );

                              setState(() {
                                item['rating'] = newRating;
                              });

                              await updateRating(item['id'], newRating);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ================= Profile =================
class ProfilePage extends StatelessWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(child: Text(username, style: const TextStyle(fontSize: 24))),
    );
  }
}
