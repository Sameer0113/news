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
                TextField(
                  controller: controller,
                  style: const TextStyle(),
                  decoration: const InputDecoration(hintText: 'search here..'),
                  onChanged: _onTextChanged,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.text.isEmpty
                        ? newsList.length
                        : searchedNewsList.length,
                    itemBuilder: (context, index) {
                      
                      return NewsItem(title: newsList[index]['title'] ?? '', subtitle:newsList[index]['description'] ?? '' , imageUrl: newsList[index]['urlToImage'] ?? 'https://github.githubassets.com/assets/GitHub-Mark-ea2971cee799.png');
                      // return Card(
                      //   child: ListTile(
                      //     trailing: Column(
                      //       children: [
                      //         Tooltip(
                      //             message: 'Add To Favourite',
                      //             child: InkWell(
                      //               onTap: () {
                      //                 showToast(
                      //                   'Added to favourite',
                      //                   context: context,
                      //                   animation: StyledToastAnimation.scale,
                      //                 );
                      //                 addToFavourite(newsList[index]['title']);
                      //               },
                      //               child: const Icon(
                      //                 Icons.favorite,
                      //                 color: Colors.red,
                      //               ),
                      //             )),
                      //         //       SizedBox(height: 5),
                      //         Tooltip(
                      //             message: 'Save News',
                      //             child: InkWell(
                      //               onTap: () {
                      //                 addItemToFireStore(
                      //                     newsList[index]['title']);
                      //                 showToast(
                      //                   'News Saved',
                      //                   context: context,
                      //                   animation: StyledToastAnimation.scale,
                      //                 );
                      //               },
                      //               child: const Icon(
                      //                 Icons.save_alt_sharp,
                      //                 color: Colors.indigo,
                      //               ),
                      //             )),
                      //       ],
                      //     ),
                      //     title: Text(controller.text.isEmpty
                      //         ? newsList[index]['title']
                      //         : searchedNewsList[index]['title']),
                      //   ),
                      // );
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

// void _onTextChanged(String value) {
//
//   if (controller.text.isNotEmpty) {
//       searchedNewsList.add(value);
//
//   }
//   setState(() {
//   });
//  // controller.clear();
//
// }
}

// Future<void> uploadItemToFirestore(String title) async {
//   try {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     CollectionReference collectionReference = firestore.collection('news');
//     await collectionReference.add({
//       'title': title,
//     });
//
//     print('News item posted to Firestore successfully!');
//   } catch (e) {
//     print('Error posting news item to Firestore: $e');
//   }
// }

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

