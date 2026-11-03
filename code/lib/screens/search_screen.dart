import 'package:flutter/material.dart';

import '../models/person.dart';
import '../services/people_repository.dart';
import '../widgets/firebase_status_banner.dart';
import '../widgets/person_tile.dart';

class SearchScreen extends StatefulWidget {
  final bool firebaseReady;

  const SearchScreen({super.key, required this.firebaseReady});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _repository = PeopleRepository();
  final _controller = TextEditingController();

  List<Person> _results = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  Future<void> _runSearch() async {
    if (!widget.firebaseReady) {
      setState(() {
        _searched = true;
        _results = [];
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    try {
      final results = await _repository.searchByName(_controller.text);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = 'Search failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Search')),
      body: Column(
        children: [
          if (!widget.firebaseReady) const FirebaseStatusBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _runSearch(),
              decoration: InputDecoration(
                labelText: 'Search by name',
                hintText: 'e.g. Arun',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _runSearch,
                ),
              ),
            ),
          ),
          if (_loading) const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _buildResultsArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsArea() {
    if (!_searched) {
      return const Center(
        child: Text('Type a name and press search.', style: TextStyle(color: Colors.grey)),
      );
    }
    if (!widget.firebaseReady) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No results — Firestore is not connected yet.\n'
            'Run flutterfire configure, add sample documents to the\n'
            '"people" collection, then search again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    if (_results.isEmpty && !_loading) {
      return const Center(child: Text('No matching records found.'));
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) => PersonTile(person: _results[index]),
    );
  }
}
