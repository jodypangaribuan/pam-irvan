import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sepatu/models/cart_item_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/profile_drawer.dart';
import 'detail_screen.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/safe_image.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late int _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  final List<Widget> _screens = [
    const ShopTab(),
    const FavoritesTab(),
    const CartTab(),
  ];

  void _onNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      endDrawer: const ProfileDrawer(),
      body: _screens[_selectedIndex],
      extendBody: true, // Add this to make body extend behind navbar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent, // Change from white to transparent
        color: Colors.black,
        buttonBackgroundColor: Colors.black,
        height: 60,
        index: _selectedIndex,
        items: const [
          Icon(Iconsax.home_1, color: Colors.white),
          Icon(Iconsax.heart, color: Colors.white),
          Icon(Iconsax.shopping_cart, color: Colors.white),
        ],
        onTap: _onNavTap,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class ShopTab extends StatefulWidget {
  const ShopTab({super.key});

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  String _selectedCategory = 'All';

  Stream<QuerySnapshot> _getProductsStream() {
    final collection = FirebaseFirestore.instance.collection('shoes');

    if (_selectedCategory == 'All') {
      return collection.orderBy('createdAt', descending: true).snapshots();
    }

    // Create composite index for this query in Firebase Console
    return collection
        .where('category', isEqualTo: _selectedCategory)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            elevation: 0,
            automaticallyImplyLeading:
                false, // Add this line to remove back button
            backgroundColor: Colors.transparent, // Change to transparent
            title: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 20, // Reduced from 24
                  width: 40, // Reduced from 46
                  color: isDark ? Colors.white : null,
                ),
                const SizedBox(width: 6), // Reduced from 8
                Text(
                  'Sneaker Shop',
                  style: GoogleFonts.montserrat(
                    // Changed from poppins to montserrat
                    fontSize: 18, // Reduced from 24
                    fontWeight: FontWeight.w700, // Changed from w900
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: 2, // Reduced from 3
                    height: 1,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Iconsax.search_normal,
                    color: isDark ? Colors.white : Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Iconsax.notification,
                    color: isDark ? Colors.white : Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Iconsax.profile_circle,
                    color: isDark ? Colors.white : Colors.black),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CollectionSlider(), // Replace _buildCollectionSlider() with this
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildCategoryScroll(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
                bottom: 80, left: 16, right: 16), // Updated padding
            sliver: StreamBuilder<QuerySnapshot>(
              stream: _getProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.box, size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCategory == 'All'
                                ? 'No products available'
                                : 'No products in $_selectedCategory category',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildShoeCard(
                      snapshot.data!.docs[index],
                    ),
                    childCount: snapshot.data!.docs.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryScroll() {
    final categories = ['All', 'Sneakers', 'Running', 'Basketball', 'Casual'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: EdgeInsets.only(
              left: category == categories.first ? 0 : 4,
              right: category == categories.last ? 0 : 4,
            ),
            child: _buildCategoryChip(category, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // Reduced padding
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.black
            : (isDark ? Colors.grey[850] : Colors.white),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedCategory = label);
        },
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildShoeCard(DocumentSnapshot shoe) {
    final data = shoe.data() as Map<String, dynamic>;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productService = Provider.of<ProductService>(context);
    final product = ProductModel.fromMap(data, shoe.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
                product: product), // Updated this line to pass the product
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[100],
                      child: data['imageBase64'] != null
                          ? Image.memory(
                              base64Decode(data['imageBase64']),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image, color: Colors.grey[600]),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StreamBuilder<List<String>>(
                      stream: productService.watchWishlist(),
                      builder: (context, snapshot) {
                        final isInWishlist =
                            snapshot.data?.contains(product.id) ?? false;

                        return InkWell(
                          onTap: () =>
                              productService.toggleWishlist(product.id),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              isInWishlist ? Iconsax.heart5 : Iconsax.heart,
                              color: isInWishlist ? Colors.red : Colors.black54,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['name'] ?? 'Unnamed Product',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${data['price']}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            try {
                              await productService.addToCart(
                                  product,
                                  1,
                                  product.sizes.isNotEmpty
                                      ? product.sizes.first
                                      : '');

                              if (mounted) {
                                // Add this check
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to cart'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                // Add this check
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding to cart: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Iconsax.shopping_bag,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add this new widget
class CollectionSlider extends StatefulWidget {
  const CollectionSlider({super.key});

  @override
  State<CollectionSlider> createState() => _CollectionSliderState();
}

class _CollectionSliderState extends State<CollectionSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _timer;
  List<Map<String, dynamic>> _collections = [];

  @override
  void initState() {
    super.initState();
    // Load collections once at start
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('collections')
        .orderBy('createdAt', descending: false)
        .get();

    if (mounted) {
      setState(() {
        _collections = snapshot.docs.map((doc) => doc.data()).toList();
      });
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_collections.isEmpty || !mounted) return;

      _currentPage = (_currentPage + 1) % _collections.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              key: const PageStorageKey('collection_slider'),
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _collections.length,
              itemBuilder: (context, index) {
                final data = _collections[index];
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _CollectionSlide(
                    key: ValueKey(
                        'collection_${index}_${data['imageBase64']?.hashCode}'),
                    data: data,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _collections.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _currentPage == index ? 24.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color:
                      _currentPage == index ? Colors.black : Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this new widget to handle individual slides
class _CollectionSlide extends StatelessWidget {
  final Map<String, dynamic> data;

  const _CollectionSlide({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (data['imageBase64'] != null)
              Image.memory(
                base64Decode(data['imageBase64']),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                cacheWidth: 800, // Add width constraint for better performance
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    data['title'] ?? 'New Collection',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (data['subtitle'] != null &&
                      data['subtitle'].toString().isNotEmpty)
                    Text(
                      data['subtitle'],
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productService = Provider.of<ProductService>(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(
            'My Wishlist',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Iconsax.profile_circle,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ],
        ),
        StreamBuilder<List<String>>(
          stream: productService.watchWishlist(),
          builder: (context, wishlistSnapshot) {
            if (wishlistSnapshot.hasError) {
              return SliverToBoxAdapter(
                child: Center(child: Text('Error: ${wishlistSnapshot.error}')),
              );
            }

            if (wishlistSnapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final wishlistIds = wishlistSnapshot.data ?? [];

            if (wishlistIds.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.heart, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Your wishlist is empty'),
                    ],
                  ),
                ),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('shoes')
                  .where(FieldPath.documentId, whereIn: wishlistIds)
                  .snapshots(),
              builder: (context, shoesSnapshot) {
                if (!shoesSnapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = shoesSnapshot.data!.docs[index];
                        final product = ProductModel.fromMap(
                            doc.data() as Map<String, dynamic>, doc.id);
                        return _buildWishlistItem(
                            context, product, productService);
                      },
                      childCount: shoesSnapshot.data!.docs.length,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWishlistItem(
      BuildContext context, ProductModel product, ProductService service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: SafeImage(
                    base64String: product.imageBase64,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => service.toggleWishlist(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Iconsax.heart5,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          service.addToCart(product).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to cart'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Iconsax.shopping_bag,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productService = Provider.of<ProductService>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login to view your cart'));
    }

    return StreamBuilder<List<CartItemModel>>(
      stream: productService.watchCart(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final cartItems = snapshot.data ?? [];

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(
                'Shopping Cart',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
              elevation: 0,
              actions: [
                if (cartItems.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => productService.clearCart(),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: Text(
                      'Clear',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ),
              ],
            ),
            if (cartItems.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.shopping_bag, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Your cart is empty'),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == cartItems.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildCheckoutSection(
                            context, cartItems, productService),
                      );
                    }
                    return _buildCartItem(
                        context, cartItems[index], productService);
                  },
                  childCount: cartItems.length + 1,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCartItem(
      BuildContext context, CartItemModel item, ProductService service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SafeImage(
                    base64String: item.product.imageBase64,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Size: EU ${item.size}',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54),
                                  onPressed: () =>
                                      service.updateCartItemQuantity(
                                          item.productId, item.quantity - 1),
                                ),
                                Text(
                                  item.quantity.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54),
                                  onPressed: () =>
                                      service.updateCartItemQuantity(
                                          item.productId, item.quantity + 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
              onPressed: () => _showDeleteConfirmation(context, item, service),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    CartItemModel item,
    ProductService service,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove ${item.product.name} from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              service.removeFromCart(item.productId);
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
      BuildContext context, List<CartItemModel> items, ProductService service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtotal = items.fold<double>(
        0, (sum, item) => sum + (item.product.price * item.quantity));
    const shipping = 10.0; // Fixed shipping cost
    final tax = subtotal * 0.1; // 10% tax
    final total = subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(
              'Subtotal', '\$${subtotal.toStringAsFixed(2)}', isDark),
          _buildSummaryItem(
              'Shipping', '\$${shipping.toStringAsFixed(2)}', isDark),
          _buildSummaryItem('Tax (10%)', '\$${tax.toStringAsFixed(2)}', isDark),
          const Divider(height: 24),
          _buildSummaryItem(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isDark,
            isTotal: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _processCheckout(context, items, service, total),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Checkout (\$${total.toStringAsFixed(2)})',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, bool isDark,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout(BuildContext context, List<CartItemModel> items,
      ProductService service, double total) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final batch = FirebaseFirestore.instance.batch();

      // Create order
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();
      batch.set(orderRef, {
        'userId': user.uid,
        'items': items
            .map((item) => {
                  'productId': item.productId,
                  'quantity': item.quantity,
                  'size': item.size,
                  'price': item.product.price,
                  'name': item.product.name,
                  'subtotal': item.product.price * item.quantity,
                })
            .toList(),
        'subtotal': items.fold<double>(
            0, (sum, item) => sum + (item.product.price * item.quantity)),
        'shipping': 10.0,
        'tax': total * 0.1,
        'total': total,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update sales statistics
      final statsRef =
          FirebaseFirestore.instance.collection('statistics').doc('sales');
      batch.set(
          statsRef,
          {
            'total': FieldValue.increment(total),
            'orders': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
            'monthlyRevenue': {
              DateTime.now().month.toString(): FieldValue.increment(total),
            },
            'dailyOrders': {
              DateTime.now().day.toString(): FieldValue.increment(1),
            }
          },
          SetOptions(merge: true));

      await batch.commit();
      await service.clearCart();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Order Successful!'),
            content: Text('Your order #${orderRef.id} has been placed.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing order: $e')),
        );
      }
    }
  }
}
