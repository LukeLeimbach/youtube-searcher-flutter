import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyReorderableList extends StatefulWidget {
  const MyReorderableList({super.key});

  @override
  State<MyReorderableList> createState() => _ReorderableListViewExampleState();
}

class _ReorderableListViewExampleState extends State<MyReorderableList> {
  final List<Map<String, dynamic>> _items = [];  
  late final Stream<QuerySnapshot> snapshot;

  @override
  void initState() {
    super.initState();
    snapshot = FirebaseFirestore.instance.collection('guilds/12345/queue').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: snapshot,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        _items.clear();
        for (var document in snapshot.data!.docs) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          data['id'] = document.id;
          _items.add(data);
          _items.sort((a, b) => a['order'] - b['order']);
        }

        return Scaffold(
          body: ReorderableListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: <Widget>[
              for (int index = 0; index < _items.length; index++)
                ListTile(
                  key: ValueKey(_items[index]['id']),
                  tileColor: index.isOdd ? const Color.fromARGB(255, 127, 181, 227) : const Color.fromARGB(255, 38, 94, 157),
                  title: Text('${_items[index]['order']}) ${_items[index]['song']}'),
                  subtitle: Text('By: ${_items[index]['artist']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color.fromARGB(255, 230, 61, 49)),
                    onPressed: () => _deleteItem(_items[index]['id']),
                  ),
                  leading: Image.network(_items[index]['thumbnailURL']),
                ),
            ],
            onReorder: (int oldIndex, int newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = _items.removeAt(oldIndex);
              _items.insert(newIndex, item);
              updateFirestoreOrder();
            },
          ),
        );
      },
    );
  }

  // Deletes item from dummy guild
  void _deleteItem(String itemId) {
    FirebaseFirestore.instance.collection('guilds/12345/queue').doc(itemId).delete();
  }


  // Updaets firestore order on item reorder
  void updateFirestoreOrder() {
    for (int i = 0; i < _items.length; i++) {
      FirebaseFirestore.instance.collection('guilds/12345/queue').doc(_items[i]['id']).update({'order': i});
    }
  }
}