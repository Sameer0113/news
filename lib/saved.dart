import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

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
          return ListView.builder(
            itemCount: snapshot.data!.size,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              return Card(
                elevation: 10,
                child: ListTile(
                  trailing: Tooltip(
                      message: 'Save News',
                      child: InkWell(
                        onTap: () async{
                          await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                             myTransaction.delete(snapshot.data!.docs[index].reference);
                          });
                          showToast("Deleted......",context:context);
                        },
                        child: const Icon(
                          Icons.delete,
                          color: Colors.indigo,
                        ),
                      )),
                  title: Text( document['title'],maxLines: 3,overflow: TextOverflow.ellipsis,),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
