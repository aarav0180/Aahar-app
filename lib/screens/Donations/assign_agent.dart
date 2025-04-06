import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_solution/screens/ngo_home.dart';
import 'package:google_solution/utils/app_colors.dart';
import 'package:google_solution/widgets/snack_bar.dart';

class AssignAgentPage extends StatefulWidget {
  final String orderId;
  final String itemName;
  final String quantity;
  final String status;
  final List<dynamic> imageUrl;

  const AssignAgentPage({
    super.key,
    required this.orderId,
    required this.itemName,
    required this.quantity,
    required this.status,
    required this.imageUrl,
  });

  @override
  _AssignAgentPageState createState() => _AssignAgentPageState();
}

class _AssignAgentPageState extends State<AssignAgentPage> {
  String? selectedAgent;
  bool isLoading = false;

  final List<String> agents = [
    "Amit Sharma",
    "Priya Verma",
    "Rahul Mehta",
    "Neha Kapoor",
    "Vikram Singh",
    "Anjali Nair",
    "Suresh Rao",
    "Divya Patel"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Agent"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Order Details at the Top
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.imageUrl!.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final imageUrl = widget.imageUrl![index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              height: 220,
                              width: MediaQuery.of(context).size.width * 0.75,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: MediaQuery.of(context).size.width * 0.75,
                                  height: 220,
                                  color: Colors.grey.shade200,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: MediaQuery.of(context).size.width * 0.75,
                                  height: 220,
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.itemName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text("Quantity: ${widget.quantity}", style: const TextStyle(fontSize: 16)),
                    Text("Status: ${widget.status}", style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Agent Selection List
            const Text(
              "Select an Agent",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  String agent = agents[index];
                  bool isSelected = agent == selectedAgent;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAgent = agent;
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: isSelected ? 6 : 2,
                      color: isSelected ? Colors.yellowAccent.withOpacity(0.9) : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            agent[0], // First letter of agent's name
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          agent,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        trailing: isSelected
                            ? const Icon(CupertinoIcons.checkmark_alt_circle, color: Colors.black)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔹 Assign Button at the Bottom
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAgent != null
                      ? () async {
                    setState(() {
                      isLoading = true;
                    });
                    try {

                      // Query the order from Firestore using the item name
                      final querySnapshot = await FirebaseFirestore.instance
                          .collection('donations')
                          .where('name', isEqualTo: widget.itemName)
                          .get();

                      if (querySnapshot.docs.isNotEmpty) {
                        // Update the first matched document's status
                        final docId = querySnapshot.docs.first.id;
                        await FirebaseFirestore.instance
                            .collection('donations')
                            .doc(docId)
                            .update({'status': 'Accepted'});

                        showCustomSnackBar(
                            context, "Assigned to $selectedAgent", true);
                        setState(() {
                          isLoading = false;
                        });

                        Navigator.popUntil(context, (route) => route.isFirst);
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        showCustomSnackBar(context, "Order not found", false);
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      showCustomSnackBar(context, "Error: $e", false);
                    }
                  }
                      : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("Assign Agent"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
