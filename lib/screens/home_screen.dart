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
import '../widgets/profile_drawer.dart';
import 'detail_screen.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                          Icon(Icons.error_outline,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 16),
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
                          Icon(Iconsax.box, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
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
              left: category == categories.first ? 0 : 12,
              right: category == categories.last ? 0 : 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          onTap: () {
                            productService.addToCart(product).then((_) {
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
                  child: Image.memory(
                    base64Decode(product.imageBase64),
                    width: double.infinity,
                    fit: BoxFit.cover,
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

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(
            'Shopping Cart',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          elevation: 0,
          actions: [
            StreamBuilder<List<CartItemModel>>(
              stream: productService.watchCart(),
              builder: (context, snapshot) {
                final hasItems = (snapshot.data?.isNotEmpty ?? false);

                return TextButton.icon(
                  onPressed: hasItems ? () => productService.clearCart() : null,
                  icon: Icon(
                    Icons.delete_outline,
                    color: hasItems ? Colors.red : Colors.grey,
                  ),
                  label: Text(
                    'Clear All',
                    style: TextStyle(
                      color: hasItems ? Colors.red : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        StreamBuilder<List<CartItemModel>>(
          stream: productService.watchCart(),
          builder: (context, cartSnapshot) {
            if (cartSnapshot.hasError) {
              return SliverToBoxAdapter(
                child: Center(child: Text('Error: ${cartSnapshot.error}')),
              );
            }

            if (cartSnapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final cartItems = cartSnapshot.data ?? [];

            if (cartItems.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: Text('Your cart is empty')),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildCartItem(context, cartItems[index], productService),
                childCount: cartItems.length,
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: StreamBuilder<double>(
            stream: productService.watchCartTotal(),
            builder: (context, totalSnapshot) {
              final total = totalSnapshot.data ?? 0.0;

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
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
                  children: [
                    _buildSummaryRow('Total', '\$${total.toStringAsFixed(2)}',
                        isDark: isDark, isTotal: true),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: total > 0
                            ? () {
                                // Implement checkout logic
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, required bool isDark}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(
      BuildContext context, CartItemModel item, ProductService service) {
    return Dismissible(
      key: Key(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => service.removeFromCart(item.productId),
      child: Builder(builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
                borderRadius: BorderRadius.circular(15),
              ),
            ],
          ),
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
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[100],
                    child: CachedNetworkImage(
                      imageUrl: 'https://via.placeholder.com/120',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Nike Air Max 270',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 2,
                              ),
                            ),
                            const Icon(Icons.delete_outline, color: Colors.red),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Size: 42 EU',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$199.99',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      size: 16,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    onPressed: () {},
                                  ),
                                  Text(
                                    '1',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 16,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
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
      }),
    );
  }
}
