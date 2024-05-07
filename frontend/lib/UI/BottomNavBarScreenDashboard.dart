import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../Functionality/DashboardLogic.dart';
import 'DashboardScreen.dart';
import 'NFTWalletScreen.dart';
import 'ChatWidgetScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Functionality/SignInAuth.dart';

class BottomNavBarScreenDashboard extends StatefulWidget {
  final AuthServiceLogin authService;

  BottomNavBarScreenDashboard({required this.authService});

  @override
  _BottomNavBarScreenDashboardState createState() =>
      _BottomNavBarScreenDashboardState();
}

class _BottomNavBarScreenDashboardState
    extends State<BottomNavBarScreenDashboard> {
  late DashboardLogic _logic;
  int _selectedIndex = 0;
  String? _walletAddress;
  bool _isLoading = true;

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _logic = DashboardLogic();
    _initializeScreens();
  }

  Future<void> _initializeScreens() async {
    _walletAddress = await _logic.fetchWalletAddress();

    setState(() {
      _screens = [
        DashboardScreen(authService: widget.authService),
        _walletAddress != null
            ? NFTListPage(address: _walletAddress!, chain: 'sepolia')
            : _buildNFTWalletPlaceholder(),
        ChatWidgetScreen(),
      ];
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    if (index == 1 && _walletAddress == null) {
      _showErrorDialog(context, "Failed to fetch wallet address.");
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildNFTWalletPlaceholder() {
    return Center(
      child: Text(
        'No wallet address available.',
        style: GoogleFonts.lato(fontSize: 18),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : PageTransitionSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child: _screens[_selectedIndex],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'NFT Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
          ),
        ],
        selectedLabelStyle: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
