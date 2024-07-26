import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/auth_service.dart';
import '../core/route.dart';
import '../widgets/slider.dart';
import 'NewsWebView.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Article>> future;
  String? searchTerm;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  List<String> categoryItems = [
    "GENERAL",
    "BUSINESS",
    "ENTERTAINMENT",
    "HEALTH",
    "SCIENCE",
    "SPORTS",
    "TECHNOLOGY",
  ];

  late String selectedCategory;

  @override
  void initState() {
    selectedCategory = categoryItems[0];
    future = getNewsData();
    super.initState();
  }

  Future<List<Article>> getNewsData() async {
    NewsAPI newsAPI = NewsAPI("9add45e817114315a5365daa99d727b6");
    return await newsAPI.getTopHeadlines(
      country: "in",
      query: searchTerm,
      category: selectedCategory,
      pageSize: 50,
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService.logout();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      Navigator.of(context).pushReplacementNamed(AppRoutes.loginRoute);
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: isSearching
            ? searchAppBar()
            : PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return AppBar(
                        title: const Text("Today's News"),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () => _signOut(context),
                          ),
                        ],
                      );
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return AppBar(
                        title: const Text("Today's News"),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () => _signOut(context),
                          ),
                        ],
                      );
                    }
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    if (userData == null) {
                      return AppBar(
                        title: const Text("Today's News"),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () => _signOut(context),
                          ),
                        ],
                      );
                    }
                    var profileImageUrl = userData['profile_image'] ?? '';

                    return AppBar(
                      title: const Text(
                        "Today's News",
                        style:
                            TextStyle(fontSize: 19.0, color: Color(0XFF1e319d)),
                      ),
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                      actions: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(profileImageUrl),
                          radius: 20,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () => _signOut(context),
                        ),
                      ],
                    );
                  },
                ),
              ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SliderDesign(),
              _buildCategories(),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Article>>(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error loading the news"),
                      );
                    } else {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return _buildNewsListView(snapshot.data!);
                      } else {
                        return const Center(
                          child: Text("No news available"),
                        );
                      }
                    }
                  },
                  future: future,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  searchAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            isSearching = false;
            searchTerm = null;
            searchController.text = "";
            future = getNewsData();
          });
        },
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Colors.orange, Colors.red],
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
        ),
      ),
      title: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white70),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              searchTerm = searchController.text;
              future = getNewsData();
            });
          },
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  Widget _buildNewsListView(List<Article> articleList) {
    return ListView.builder(
      itemBuilder: (context, index) {
        Article article = articleList[index];
        return _buildNewsItem(article);
      },
      itemCount: articleList.length,
    );
  }

  Widget _buildNewsItem(Article article) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsWebView(url: article.url ?? ''),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Image.network(
                  article.urlToImage ?? "",
                  fit: BoxFit.fitHeight,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title!,
                      maxLines: 2,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      article.source.name!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCategory = categoryItems[index];
                  future = getNewsData();
                });
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all<Color>(
                  categoryItems[index] == selectedCategory
                      ? Colors.blueAccent.shade700.withOpacity(0.5)
                      : Colors.blueAccent.shade700,
                ),
              ),
              child: Text(
                categoryItems[index],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        itemCount: categoryItems.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
