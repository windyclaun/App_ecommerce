import 'package:flutter/material.dart';
import 'package:projectakhir_mobile/pages/add_product_page.dart';
import 'package:projectakhir_mobile/pages/cart_page.dart';
import 'package:projectakhir_mobile/pages/main_product_page.dart';
import 'package:projectakhir_mobile/pages/profile_page.dart';

class BasePage extends StatefulWidget {
  final String? token;
  final String? username;
  final String? role;
  final String? password;

  const BasePage({
    super.key,
    this.token,
    this.username,
    this.role,
    this.password,
  });

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int _selectedIndex = 0;

  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();
  final GlobalKey<CartPageState> _cartKey = GlobalKey<CartPageState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  void _onCheckoutSuccess() {
    if (!mounted) return;

    setState(() {
      _selectedIndex = widget.role == 'admin' ? 3 : 2;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _profileKey.currentState?.refreshOrderHistory();
    });
  }

  void _onCartUpdated() {
    _cartKey.currentState?.loadCart();
  }

  void _onProductAdded() {
    setState(() {});
  }

  List<Widget> _buildPages() {
    final List<Widget> pages = [
      MainProductPage(
        token: widget.token,
        username: widget.username,
        role: widget.role,
        onCartUpdated: _onCartUpdated,
        onProductAdded: _onProductAdded,
      ),
    ];

    if (widget.token != null) {
      pages.addAll([
        (widget.role == 'admin')
            ? AddProductPage(
                token: widget.token, onProductAdded: _onProductAdded)
            : CartPage(
                key: _cartKey,
                token: widget.token,
                onCheckoutDone: _onCheckoutSuccess,
              ),
        ProfilePage(
          token: widget.token,
          username: widget.username,
          password: widget.password,
          role: widget.role,
          key: _profileKey,
        ),
      ]);
    }

    return pages;
  }

  void _onItemTapped(int index) {
    if (!mounted) return;

    if (widget.token == null && index != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login to access this feature"),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() => _selectedIndex = 0);
      return;
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();
    final isLoggedIn = widget.token != null;
    final isAdmin = widget.role == 'admin';

    return PopScope(
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: isLoggedIn
            ? BottomNavigationBar(
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  (isAdmin)
                      ? const BottomNavigationBarItem(
                          icon: Icon(Icons.add_circle),
                          label: 'Add Product',
                        )
                      : const BottomNavigationBarItem(
                          icon: Icon(Icons.shopping_cart),
                          label: 'Cart',
                        ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.green,
                unselectedItemColor: Colors.grey,
                type: BottomNavigationBarType.fixed,
                onTap: _onItemTapped,
              )
            : null,
      ),
    );
  }
}
