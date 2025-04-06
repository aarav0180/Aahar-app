import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Donations',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: // Grid view with cards
              GridView.builder(
                shrinkWrap: true,
                //physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 8,
                itemBuilder: (context, index) => const DonationCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // // Search Bar
  // Widget _buildSearchBar() {
  //
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 8,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: TextField(
  //       controller: _controller,
  //       decoration: InputDecoration(
  //         filled: true,
  //         fillColor: Colors.white,
  //         prefixIcon: const Icon(Icons.search, color: Colors.black54),
  //         hintText: 'Search campaign...',
  //         hintStyle: TextStyle(color: Colors.grey[500]),
  //         suffixIcon: _controller.text.isNotEmpty
  //             ? IconButton(
  //           icon: const Icon(Icons.clear, color: Colors.black54),
  //           onPressed: () => _controller.clear(),
  //         )
  //             : null,
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(12),
  //           borderSide: BorderSide.none,
  //         ),
  //         contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  //       ),
  //       onChanged: (value) {
  //         setState(() {});
  //       },
  //     ),
  //   );
  // }

  // // Donation Card
  // Widget _buildDonationCard() {
  //   return Card(
  //     elevation: 4,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Image placeholder
  //         ClipRRect(
  //           borderRadius: const BorderRadius.only(
  //             topLeft: Radius.circular(12),
  //             topRight: Radius.circular(12),
  //           ),
  //           child: Image.network(
  //             'https://dummyimage.com/250x150/000/fff&text=image',
  //             width: double.infinity,
  //             height: 120,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.all(12.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 'Social Project 🌟',
  //                 style: TextStyle(
  //                   color: Colors.orange,
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               const Text(
  //                 'Share Your Food, Share Your Love',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               LinearProgressIndicator(
  //                 value: 0.5,
  //                 backgroundColor: Colors.grey[300],
  //                 valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
  //               ),
  //               const SizedBox(height: 8),
  //               const Text(
  //                 'Collected: \$500.000',
  //                 style: TextStyle(fontSize: 14, color: Colors.black54),
  //               ),
  //               const Text(
  //                 '30 days to go',
  //                 style: TextStyle(fontSize: 12, color: Colors.black54),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}


//search bar code improved
class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          hintText: 'Search campaign...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.black54),
            onPressed: () => _controller.clear(),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }
}


//improved donation widget
class DonationCard extends StatelessWidget {
  const DonationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with placeholder
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              'https://plus.unsplash.com/premium_photo-1682092585257-58d1c813d9b4?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),

          // Expanded content area to prevent overflow
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag
                  Container(

                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Social Project 🌟',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  const Text(
                    'Share Your Food, Share Your Love',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Progress bar
                  LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color.fromRGBO(150, 90, 0, 1)),
                  ),
                  const SizedBox(height: 8),

                  // Donation stats
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Collected: 300 Kgs',
                        style: TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                      Text(
                        '3 days to go',
                        style: TextStyle(fontSize: 10, color: Colors.black54),
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