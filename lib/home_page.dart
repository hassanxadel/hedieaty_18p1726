import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _setupFriendsListener();
    searchController.addListener(() {
      filterFriends();
    });
  }

  void _setupFriendsListener() {
    _firestoreService.getFriends().listen(
      (friendsList) {
        setState(() {
          friends = friendsList;
          filterFriends();
          isLoading = false;
          error = null;
        });
      },
      onError: (e) {
        setState(() {
          error = 'Error loading friends: $e';
          isLoading = false;
        });
      },
    );
  }

  void filterFriends() {
    setState(() {
      if (searchController.text.isEmpty) {
        filteredFriends = List.from(friends);
      } else {
        filteredFriends = friends
            .where((friend) => friend['name']
                .toString()
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;

    if (isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      mainContent = Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    } else if (filteredFriends.isEmpty) {
      mainContent = const Center(
        child: Text('No friends found. Add some friends to get started!'),
      );
    } else {
      mainContent = GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two squares per row
          childAspectRatio: 1, // Make each item a square
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: filteredFriends.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/events',
                arguments: {'friendId': friends[index]['id']},
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.secondaryColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            backgroundImage: filteredFriends[index]['image'] !=
                                    null
                                ? NetworkImage(filteredFriends[index]['image'])
                                : const AssetImage(
                                        'assets/images/default_avatar.jpeg')
                                    as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          filteredFriends[index]['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hedieaty Home'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () {
                      Navigator.pushNamed(context, '/addFriend');
                    }),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              // Wrap in a Row to allow multiple children
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      filterFriends();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: mainContent,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity, // Full width button
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/myEvents');
                },
                child: const Text('Add Your Own Event/List'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
