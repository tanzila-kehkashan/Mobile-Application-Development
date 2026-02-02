import 'package:flutter/material.dart';

// Custom color derived from the Figma design's background (light taupe/mauve)
const Color _backgroundColor = Color(0xFFEBE3E3);
// Dark text/icon color
const Color _foregroundColor = Colors.black87;
// Custom color for the 'Yes' button background
const Color _buttonColor = Color(0xFFCBB8A1);
// Custom color for the 'X' icon (dark purple/blue)
const Color _closeIconColor = Color(0xFF5A4C6B);

void main() {
  runApp(const MenuApp());
}

class MenuApp extends StatelessWidget {
  const MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  // Helper widget to build each menu list item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    // The Colours item has a gradient icon in the design. We will use
    // a standard icon here for simplicity, but use the correct size/color.
    bool isColorful = false,
  }) {
    // The icons in the design appear slightly thinner and outline-based.
    // The spacing is also very wide on the left.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: Row(
        children: [
          // Use a SizedBox to match the wide margin before the icon
          const SizedBox(width: 16),
          Icon(
            icon,
            color: _foregroundColor,
            size: 24, // Matched size for visual fidelity
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: _foregroundColor,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: _foregroundColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  // Function to show the custom Sign Out Dialog
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return Dialog(
          // Shape to match the highly rounded corners of the popup image
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          // Set the internal padding and width constraint
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // Adjust width as needed
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
            child: Stack(
              clipBehavior: Clip.none, // Allows the close button to be outside the box
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Title: Sign out ?
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 8.0),
                      child: Text(
                        'Sign out ?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _foregroundColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                    // Subtext: If you answer yes...
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30.0),
                      child: Text(
                        'If you answer yes, you will be signed\nout from the app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: _foregroundColor,
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Yes Button
                    SizedBox(
                      width: double.infinity,
                      height: 55, // Fixed height to match design
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Close dialog
                          // Sign out handled
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonColor, // Light taupe background
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0), // Highly rounded corners
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white, // White text color for contrast
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // No Button/Text
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close dialog, which is the desired action
                        // Cancelled
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _foregroundColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10), // Final bottom space
                  ],
                ),

                // Close/X Icon Button (positioned absolutely at top right)
                Positioned(
                  top: -10, // Adjust to position it slightly outside
                  right: -10, // Adjust to position it slightly outside
                  child: Material(
                    color: Colors.transparent, // Match the dialog background's general area
                    child: InkWell(
                      onTap: () {
                        Navigator.of(dialogContext).pop(); // Close dialog
                        // Closed via X button
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _closeIconColor, width: 2), // Dark border
                        ),
                        child: const Icon(
                          Icons.close,
                          color: _closeIconColor, // Dark icon color
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        // Set AppBar color to match the body background color
        backgroundColor: _backgroundColor,
        // Remove the shadow/elevation
        elevation: 0,
        // Custom leading icon (back arrow)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _foregroundColor),
          onPressed: () {
            // Navigator.pop(context) in a real app
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Large White Graduation Cap Icon
            const Padding(
              padding: EdgeInsets.only(top: 40.0, bottom: 60.0),
              child: Icon(
                Icons.school, // Mortarboard icon
                color: Colors.white,
                size: 100, // Large size to match design
              ),
            ),

            // 2. Menu Items List
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Profile',
            ),
            _buildMenuItem(
              icon: Icons.border_color, // Used for 'Home Feed'
              title: 'Home Feed',
            ),
            _buildMenuItem(
              icon: Icons.work_outline,
              title: 'Jobs',
            ),
            _buildMenuItem(
              icon: Icons.chat_bubble_outline,
              title: 'Chat',
            ),
            _buildMenuItem(
              icon: Icons.menu_book_outlined,
              title: 'Events',
            ),
            _buildMenuItem(
              icon: Icons.palette_outlined, // Used for 'Colours'
              title: 'Colours',
              isColorful: true,
            ),
            _buildMenuItem(
              icon: Icons.contact_page_outlined, // Used for 'Contact'
              title: 'Contact',
            ),

            const SizedBox(height: 70), // Spacing before the button

            // 3. Sign Out Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              height: 55, // Fixed height to match design
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Highly rounded corners
                // Optional: subtle shadow to make it pop like in the design
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // CALL THE DIALOG FUNCTION HERE
                  _showSignOutDialog(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: _foregroundColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: _foregroundColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40), // Spacing after the button

            // 4. ABOUT APP Text
            TextButton(
              onPressed: () {
                // Handle navigation to About App screen
              },
              child: const Text(
                'ABOUT APP',
                style: TextStyle(
                  fontSize: 16,
                  color: _foregroundColor,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline, // Underlined
                  decorationColor: _foregroundColor,
                  decorationThickness: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 40),
            // Padding for the bottom safe area/indicator
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
