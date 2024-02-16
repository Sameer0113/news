import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> newsList = [];
  List<dynamic> searchedNewsList = [];

  List<String> favouriteNewsList = [];
  final controller = TextEditingController();

  addToFavourite(newsItem) async {
    favouriteNewsList.add(newsItem);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setStringList("item", favouriteNewsList ?? []);
    //Set an animation
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=in&apiKey=fe29e3fd906342ffad5fc3c4d9d19e66'));
    if (response.statusCode == 200) {
      setState(() {
        newsList = json.decode(response.body)['articles'];
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: newsList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blueGrey,
              ),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 12,right: 12,top: 8,bottom: 6.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  padding: const EdgeInsets.only(left: 8.0,right: 8),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(),
                    decoration:  const InputDecoration(hintText: 'search here..',
                      border: InputBorder.none,
                    ),
                    onChanged: _onTextChanged,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    cacheExtent: 1000,
                    itemCount: controller.text.isEmpty
                        ? newsList.length
                        : searchedNewsList.length,
                    itemBuilder: (context, index) {
                      final item = searchedNewsList.isNotEmpty ? searchedNewsList[index] : newsList[index];
                      return NewsItem(title: item['title'] ?? '', subtitle:item['description'] ?? '' , imageUrl: item['urlToImage'] ?? 'https://github.githubassets.com/assets/GitHub-Mark-ea2971cee799.png');
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _onTextChanged(String value) {
    if (value.isNotEmpty) {
      searchedNewsList = newsList
          .where((element) => element.toString().toLowerCase().contains(value))
          .toList();
      setState(() {});
    }

  }

}

Future addItemToFireStore(value) async {
  await FirebaseFirestore.instance.collection('items').add({'title': value});
}



class NewsItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;

  NewsItem({required this.title, required this.subtitle, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Subtitle
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 16),
            ),
          ),

          // Save button
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                   // Show
                    addItemToFireStore(title);
                    // Implement save functionality here
                    // You can add your logic to save the image
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

