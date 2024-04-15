import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class YoutubeSearch extends StatefulWidget {
  const YoutubeSearch({super.key});

  @override
  _YoutubeSearchState createState() => _YoutubeSearchState();
}

class _YoutubeSearchState extends State<YoutubeSearch> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<dynamic> _results = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchYoutube(_searchController.text);
    });
  }

  Future<void> _searchYoutube(String query) async {
    try {
      // Reset search if query is empty
      if (query.isEmpty) {
        setState(() {
          _results = [];
        });
        return;
      }

      // Query youtube info
      final response = await http.get(Uri.parse('https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=AIzaSyCtiJxlw_gu-BJcFb_xT0mHaoM-GVsNPIU'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Check if the 'items' field exists and is a list
        if (data['items'] != null && data['items'] is List) {
          setState(() {
            _results = data['items'];
          });
        } else {
          // Handle the case when 'items' is not a list
          setState(() {
            _results = [];
          });
          debugPrint('No items found or items is not a list');
        }
      } else {
        // Throw exception if no response recieved
        throw Exception('Failed to load video list');
      }
    } catch (err) {
      // Handle exceptions by clearing results and printing error
      setState(() {
        _results = [];
      });
      debugPrint('Error searching YouTube: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search YouTube',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              var video = _results[index];
              return ListTile(
                title: Text(video['snippet']['title']),
                subtitle: Text(video['snippet']['channelTitle']),
                onTap: () => _addToFirestore(video),
              );
            },
          ),
        ),
      ],
    );
  }
   
  void _addToFirestore(dynamic video) async {
    var queueCollection = FirebaseFirestore.instance.collection('guilds/12345/queue');
    
    // Get the current number of documents in the collection to determine the new order
    var querySnapshot = await queueCollection.get();
    int newOrder = querySnapshot.docs.length;

    var docRef = queueCollection.doc();

    // Set the new document data
    docRef.set({
      'artist': video['snippet']['channelTitle'],
      'order': newOrder,
      'song': video['snippet']['title'],
      'thumbnailURL': video['snippet']['thumbnails']['medium']['url'],
      'url': 'https://www.youtube.com/watch?v=${video['id']['videoId']}'
    });
    // print('Order of ${video['snippet']['title']} set to $newOrder');
  }
}
