import 'package:flutter/material.dart';
class SearchScreen extends StatefulWidget {
  final String searchQuery;
  static const routeName='/search-screen';
  const SearchScreen({super.key,required this.searchQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(widget.searchQuery),);
  }
}
