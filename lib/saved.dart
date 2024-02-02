import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SavedItems extends StatefulWidget {
  @override
  State<SavedItems> createState() => _SavedItemsState();
}

class _SavedItemsState extends State<SavedItems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // return ListView(
          //   children: snapshot.data!.docs.map((document) {
          //     return Container(
          //       child: Center(child: Text(document['title'])),
          //     );
          //   }).toList(),
          // );
          return ListView.builder(
            itemCount: snapshot.data!.size,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  trailing: Tooltip(
                      message: 'Save News',
                      child: InkWell(
                        onTap: () async{
                          Future.delayed(const Duration(seconds: 1),()=> const Center(child: CircularProgressIndicator()));
                          await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                             myTransaction.delete(snapshot.data!.docs[index].reference);
                          });
                        },
                        child: const Icon(
                          Icons.delete,
                          color: Colors.indigo,
                        ),
                      )),
                  title: Text(snapshot.data!.docs.map((e) => e['title']).toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
