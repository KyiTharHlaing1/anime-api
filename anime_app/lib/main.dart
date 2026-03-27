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
      home: const AnimeListPage(),
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
    final res = await http.get(Uri.parse(baseUrl));
    setState(() {
      animes = jsonDecode(res.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anime List")),
      body: ListView.builder(
        itemCount: animes.length,
        itemBuilder: (context, index) {
          final anime = animes[index];

          return ListTile(
            leading: Image.network(
              anime['image_url'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(anime['title']),
            subtitle: Text("⭐ ${anime['rating']}"),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailPage(anime: anime)),
              );
              fetchAnimes(); // refresh
            },
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

  Future updateRating() async {
    await http.patch(
      Uri.parse("$baseUrl/${anime['id']}/rating"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rating': 5}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(anime['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(anime['image_url']),
            const SizedBox(height: 10),
            Text(anime['title'], style: const TextStyle(fontSize: 20)),
            Text(anime['description']),
            const SizedBox(height: 10),
            Text("⭐ ${anime['rating']}"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await updateRating();
                Navigator.pop(context);
              },
              child: const Text("Rate 5 ⭐"),
            ),
          ],
        ),
      ),
    );
  }
}
