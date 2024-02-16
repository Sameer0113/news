import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'latest.dart';

class Favourite extends StatefulWidget {
  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  final controller = TextEditingController();
  List<dynamic> topHeadlinesList = [];
  List<dynamic> searchTopHeadlinesList = [];



  Future<void> fetchTopHeadLines() async {
    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=fe29e3fd906342ffad5fc3c4d9d19e66'));
    if (response.statusCode == 200) {
      setState(() {
        topHeadlinesList = json.decode(response.body)['articles'];
      });
    } else {
      throw Exception('Failed to load news');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchTopHeadLines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: topHeadlinesList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.teal,)
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
                    itemCount: searchTopHeadlinesList.isEmpty ?topHeadlinesList.length : searchTopHeadlinesList.length,
                    itemBuilder: (context, index) {
                      final item = searchTopHeadlinesList.isEmpty ? topHeadlinesList[index] : searchTopHeadlinesList[index];
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
      searchTopHeadlinesList = topHeadlinesList
          .where((element) => element.toString().toLowerCase().contains(value))
          .toList();
      setState(() {});
    }

  }


}
