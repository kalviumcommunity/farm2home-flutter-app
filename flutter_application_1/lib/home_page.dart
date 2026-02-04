import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ProductsPage(),
    FarmersPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Farmers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Products Page
class ProductsPage extends StatefulWidget {
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fresh Products'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: products.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No products available yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Farmers will add fresh products soon!',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var product = snapshot.data!.docs[index];
              return ProductCard(
                name: product['name'] ?? 'Product',
                price: product['price']?.toString() ?? '0',
                farmer: product['farmer'] ?? 'Unknown',
                unit: product['unit'] ?? 'kg',
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final unitController = TextEditingController(text: 'kg');
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g., Fresh Tomatoes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: unitController,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  hintText: 'kg, lb, dozen, etc.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Product details...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                products.add({
                  'name': nameController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'unit': unitController.text,
                  'description': descriptionController.text,
                  'farmer': FirebaseAuth.instance.currentUser?.email ?? 'Anonymous',
                  'createdAt': Timestamp.now(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product added successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String name;
  final String price;
  final String farmer;
  final String unit;

  const ProductCard({
    required this.name,
    required this.price,
    required this.farmer,
    required this.unit,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    if (user == null) return;
    final snapshot = await firestore
        .collection('favorites')
        .where('userId', isEqualTo: user!.uid)
        .where('productName', isEqualTo: widget.name)
        .limit(1)
        .get();
    if (mounted) {
      setState(() => isFavorite = snapshot.docs.isNotEmpty);
    }
  }

  Future<void> _toggleFavorite() async {
    if (user == null) return;

    setState(() => isFavorite = !isFavorite);

    try {
      if (isFavorite) {
        await firestore.collection('favorites').add({
          'userId': user!.uid,
          'productName': widget.name,
          'price': double.tryParse(widget.price) ?? 0,
          'farmer': widget.farmer,
          'addedAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.name} added to favorites!'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final snapshot = await firestore
            .collection('favorites')
            .where('userId', isEqualTo: user!.uid)
            .where('productName', isEqualTo: widget.name)
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.name} removed from favorites!'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isFavorite = !isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating favorites'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.green.shade50],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.eco, size: 60, color: Colors.green.shade700),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${widget.price} / ${widget.unit}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By: ${widget.farmer.split('@').first}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Farmers Page
class FarmersPage extends StatefulWidget {
  const FarmersPage({Key? key}) : super(key: key);

  @override
  State<FarmersPage> createState() => _FarmersPageState();
}

class _FarmersPageState extends State<FarmersPage> {
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeDummyData();
  }

  Future<void> _initializeDummyData() async {
    try {
      // Create dummy farmers if they don't exist
      final farmerRef = firestore.collection('farmers');
      final snapshot = await farmerRef.get();

      if (snapshot.docs.isEmpty) {
        final dummyFarmers = [
          {
            'name': 'John Smith',
            'email': 'john@farm2home.com',
            'description': 'Organic vegetables and fruits',
            'location': 'California',
            'phone': '+1 (555) 123-4567',
            'specialty': 'Organic Produce',
          },
          {
            'name': 'Maria Garcia',
            'email': 'maria@farm2home.com',
            'description': 'Fresh dairy products',
            'location': 'Wisconsin',
            'phone': '+1 (555) 234-5678',
            'specialty': 'Dairy',
          },
          {
            'name': 'David Lee',
            'email': 'david@farm2home.com',
            'description': 'Premium grains and seeds',
            'location': 'Kansas',
            'phone': '+1 (555) 345-6789',
            'specialty': 'Grains & Seeds',
          },
          {
            'name': 'Sarah Johnson',
            'email': 'sarah@farm2home.com',
            'description': 'Seasonal produce',
            'location': 'Florida',
            'phone': '+1 (555) 456-7890',
            'specialty': 'Seasonal Produce',
          },
          {
            'name': 'Ahmed Hassan',
            'email': 'ahmed@farm2home.com',
            'description': 'Herbs and spices',
            'location': 'Texas',
            'phone': '+1 (555) 567-8901',
            'specialty': 'Herbs & Spices',
          },
        ];

        for (var farmer in dummyFarmers) {
          await farmerRef.add(farmer);
        }
      }

      // Create dummy products if they don't exist
      final productRef = firestore.collection('products');
      final productSnapshot = await productRef.get();

      if (productSnapshot.docs.isEmpty) {
        final dummyProducts = [
          {
            'name': 'Fresh Tomatoes',
            'price': 3.99,
            'unit': 'kg',
            'farmer': 'john@farm2home.com',
            'description': 'Organic red tomatoes',
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Organic Spinach',
            'price': 2.49,
            'unit': 'bunch',
            'farmer': 'john@farm2home.com',
            'description': 'Fresh leafy greens',
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Fresh Milk',
            'price': 4.50,
            'unit': 'liter',
            'farmer': 'maria@farm2home.com',
            'description': 'Pure fresh milk',
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Whole Wheat',
            'price': 5.99,
            'unit': 'kg',
            'farmer': 'david@farm2home.com',
            'description': 'Premium whole wheat grains',
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Strawberries',
            'price': 6.99,
            'unit': 'kg',
            'farmer': 'sarah@farm2home.com',
            'description': 'Sweet and fresh strawberries',
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Organic Turmeric',
            'price': 8.99,
            'unit': 'kg',
            'farmer': 'ahmed@farm2home.com',
            'description': 'Premium organic turmeric',
            'createdAt': Timestamp.now(),
          },
        ];

        for (var product in dummyProducts) {
          await productRef.add(product);
        }
      }

      // Create dummy orders for the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final orderRef = firestore.collection('orders');
        final orderSnapshot = await orderRef
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (orderSnapshot.docs.isEmpty) {
          final dummyOrders = [
            {
              'userId': user.uid,
              'products': ['Fresh Tomatoes', 'Organic Spinach'],
              'total': 6.48,
              'status': 'delivered',
              'createdAt': Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 5)),
              ),
            },
            {
              'userId': user.uid,
              'products': ['Fresh Milk', 'Whole Wheat'],
              'total': 10.49,
              'status': 'delivered',
              'createdAt': Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 2)),
              ),
            },
            {
              'userId': user.uid,
              'products': ['Strawberries'],
              'total': 6.99,
              'status': 'pending',
              'createdAt': Timestamp.now(),
            },
          ];

          for (var order in dummyOrders) {
            await orderRef.add(order);
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing dummy data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Farmers'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('farmers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Farmers Available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final farmer = snapshot.data!.docs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(
                      Icons.person,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    farmer['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        farmer['description'] ?? '',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            farmer['location'] ?? '',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            farmer['phone'] ?? '',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.orange,
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _buildFarmerDetails(farmer),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFarmerDetails(QueryDocumentSnapshot farmer) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.orange.shade100,
                  child: const Icon(Icons.person, size: 40, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  farmer['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    farmer['specialty'] ?? 'Farmer',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.description, farmer['description'] ?? ''),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.location_on, farmer['location'] ?? ''),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.phone, farmer['phone'] ?? ''),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.email, farmer['email'] ?? ''),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Viewing ${farmer['name']}\'s products',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('View Products'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}

