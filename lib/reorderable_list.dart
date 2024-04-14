import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyReorderableList extends StatefulWidget {
  const MyReorderableList({super.key});

  @override
  State<MyReorderableList> createState() => _ReorderableListViewExampleState();
}

class _ReorderableListViewExampleState extends State<MyReorderableList> {
  final List<Map<String, dynamic>> _items = [];  
  late final Stream<QuerySnapshot> _itemsStream;

  @override
  void initState() {
    super.initState();
    _itemsStream = FirebaseFirestore.instance.collection('guilds/12345/queue').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _itemsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        _items.clear();
        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          data['id'] = document.id;  // Ensure you have 'id' for Key value
          _items.add(data);
        });

        return ReorderableListView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          children: <Widget>[
            for (int index = 0; index < _items.length; index++)
              ListTile(
                key: ValueKey(_items[index]['id']),
                tileColor: index.isOdd ? Colors.blue[700] : Colors.blue[800],
                title: Text('Item ${_items[index]['song']} by ${_items[index]['artist']}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem(_items[index]['id']),
                ),
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
        );
      },
    );
  }

  void _deleteItem(String itemId) {
    FirebaseFirestore.instance.collection('guilds/12345/queue').doc(itemId).delete();
  }

  void updateFirestoreOrder() {
    for (int i = 0; i < _items.length; i++) {
      FirebaseFirestore.instance.collection('guilds/12345/queue').doc(_items[i]['id']).update({'order': i});
    }
  }
}