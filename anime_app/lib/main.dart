import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// ✅ 本地后端地址
const String baseUrl = "http://10.0.2.2:3333/api/animes";
const String loginUrl = "http://10.0.2.2:3333/api/login";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anime App',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

// ================= 1. 登录页面 (Login Screen) =================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter info')));
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        if (!mounted) return;
        // 🚀 核心改动：登录成功，带着用户信息跳转
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AnimeListPage(username: usernameController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login Failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anime Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_filter, size: 80, color: Colors.indigo),
            const SizedBox(height: 30),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
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
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 2. 列表页面 (Data Display Screen) =================
class AnimeListPage extends StatefulWidget {
  final String username; // 接收用户名
  const AnimeListPage({super.key, required this.username});

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  List animes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnimes();
  }

  Future<void> fetchAnimes() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        setState(() {
          animes = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Anime List")),
      // ✨ 这里就是你的 Profile 入口：侧边栏
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              accountName: Text(
                widget.username,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: const Text("Status: Online"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.indigo),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("My Profile"),
              onTap: () {
                Navigator.pop(context); // 关抽屉
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(username: widget.username),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: animes.length,
              itemBuilder: (context, index) {
                final anime = animes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Image.network(
                      anime['image_url'] ?? '',
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.movie),
                    ),
                    title: Text(anime['title'] ?? 'Unknown'),
                    subtitle: Text("⭐ ${anime['rating'] ?? '0.0'}"),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(anime: anime),
                        ),
                      );
                      fetchAnimes();
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ================= 3. 个人信息页面 (Profile Screen) =================
class ProfilePage extends StatelessWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.person, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Anime Enthusiast",
              style: TextStyle(color: Colors.grey),
            ),
            const Padding(padding: EdgeInsets.all(30), child: Divider()),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
              subtitle: Text("admin@example.com"),
            ),
            const ListTile(
              leading: Icon(Icons.location_on),
              title: Text("Location"),
              subtitle: Text("TiDB Cloud Server"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 4. 详情页面 =================
class DetailPage extends StatelessWidget {
  final Map anime;
  const DetailPage({super.key, required this.anime});

  Future<void> updateRating(BuildContext context, double newRating) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/${anime['id']}/rating"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rating': newRating}),
      );
      if (response.statusCode == 200) Navigator.pop(context);
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double current = double.tryParse(anime['rating'].toString()) ?? 0.0;
    return Scaffold(
      appBar: AppBar(title: Text(anime['title'])),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              anime['image_url'] ?? '',
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(anime['description'] ?? 'No description'),
                  const SizedBox(height: 20),
                  Text(
                    "Current Rating: ⭐ ${current.toStringAsFixed(1)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () =>
                            updateRating(context, (current - 0.5).clamp(0, 10)),
                        icon: const Icon(Icons.remove),
                        label: const Text("0.5"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            updateRating(context, (current + 0.5).clamp(0, 10)),
                        icon: const Icon(Icons.add),
                        label: const Text("0.5"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
