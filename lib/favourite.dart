import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favourite extends StatefulWidget {
  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  List<String> favouriteNewsList = [];

  getFavourite() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    favouriteNewsList = preferences.getStringList("item") ?? [];
    setState(() {

    });
    //Set an animation
  }

  removeFavourite(String item) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    favouriteNewsList = preferences.getStringList("item") ?? [];
    if(favouriteNewsList.isNotEmpty){
      favouriteNewsList.removeWhere((element) => element == item);
      preferences.setStringList("item", favouriteNewsList);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFavourite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: favouriteNewsList.isEmpty
          ? const Center(
              child: Text('nothing in favourite... please add ')
            )
          : ListView.builder(
              itemCount: favouriteNewsList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    trailing: Tooltip(
                        message: 'Save News',
                        child: InkWell(
                          onTap: () {
                            showToast(
                              'remove from  favourite',
                              context: context,
                              animation: StyledToastAnimation.scale,
                            );
                            removeFavourite(
                                favouriteNewsList[index].toString());
                          },
                          child: const Icon(
                            Icons.remove_circle,
                            color: Colors.indigo,
                          ),
                        )),
                    title: Text(favouriteNewsList[index].toString()),
                  ),
                );
              },
            ),
    );
  }
}
