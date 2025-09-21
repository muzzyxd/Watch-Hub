// import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:io' as io; // For mobile
// import 'dart:html' as html; // For web

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final supabase = Supabase.instance.client;
//   String? profileUrl;
//   String? name;
//   String? email;
//   String? phone;
//   String? address;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) return;

//     final response = await supabase
//         .from('profiles')
//         .select()
//         .eq('id', user.id)
//         .maybeSingle();

//     setState(() {
//       email = user.email;
//       name = response?['name'] ?? "User";
//       phone = response?['phone'];
//       address = response?['address'];
//       profileUrl = response?['profile_url'];
//     });
//   }

//   Future<void> _pickProfileImage() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) return;

//     Uint8List? bytes;
//     String fileName = "${user.id}.jpg";

//     if (kIsWeb) {
//       // ---------------- Web ----------------
//       final uploadInput = html.FileUploadInputElement();
//       uploadInput.accept = 'image/*';
//       uploadInput.click();

//       await uploadInput.onChange.first;
//       final files = uploadInput.files;
//       if (files == null || files.isEmpty) return;

//       final file = files[0];
//       fileName = "${user.id}_${file.name}";
//       final reader = html.FileReader();
//       reader.readAsArrayBuffer(file);
//       await reader.onLoadEnd.first;
//       bytes = reader.result as Uint8List;
//     } else {
//       // ---------------- Mobile/Desktop ----------------
//       final picker = ImagePicker();
//       final picked = await picker.pickImage(source: ImageSource.gallery);
//       if (picked == null) return;

//       fileName = "${user.id}_${picked.name}";
//       final file = io.File(picked.path);
//       bytes = await file.readAsBytes();
//     }

//     try {
//       // Upload to Supabase
//       await supabase.storage.from('profile_pics').uploadBinary(
//         fileName,
//         bytes,
//         fileOptions: const FileOptions(upsert: true),
//       );

//       // Get public URL
//       final url = supabase.storage.from('profile_pics').getPublicUrl(fileName);

//       // Update profile table
//       await supabase
//           .from('profiles')
//           .update({'profile_url': url})
//           .eq('id', user.id);

//       setState(() => profileUrl = url);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile picture uploaded!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e')),
//       );
//     }
//   }

//   void _editProfile() {
//     final nameController = TextEditingController(text: name);
//     final phoneController = TextEditingController(text: phone);
//     final addressController = TextEditingController(text: address);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Edit Profile"),
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: "Name"),
//               ),
//               TextField(
//                 controller: phoneController,
//                 decoration: const InputDecoration(labelText: "Phone"),
//               ),
//               TextField(
//                 controller: addressController,
//                 decoration: const InputDecoration(labelText: "Shipping Address"),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final user = supabase.auth.currentUser;
//               if (user != null) {
//                 await supabase.from('profiles').upsert({
//                   'id': user.id,
//                   'name': nameController.text,
//                   'phone': phoneController.text,
//                   'address': addressController.text,
//                 });
//                 setState(() {
//                   name = nameController.text;
//                   phone = phoneController.text;
//                   address = addressController.text;
//                 });
//               }
//               Navigator.pop(context);
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = supabase.auth.currentUser;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Profile")),
//       body: user == null
//           ? const Center(child: Text("Please login to see your profile"))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Profile Picture
//                   Center(
//                     child: Stack(
//                       children: [
//                         CircleAvatar(
//                           radius: 50,
//                           backgroundImage: profileUrl != null && profileUrl!.isNotEmpty
//                               ? NetworkImage(profileUrl!)
//                               : const AssetImage("assets/profile.png") as ImageProvider,
//                         ),
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: GestureDetector(
//                             onTap: _pickProfileImage,
//                             child: const CircleAvatar(
//                               radius: 16,
//                               backgroundColor: Colors.teal,
//                               child: Icon(
//                                 Icons.camera_alt,
//                                 size: 18,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     name ?? "User",
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   Text(email ?? "", style: const TextStyle(color: Colors.grey)),
//                   const SizedBox(height: 10),
//                   ElevatedButton.icon(
//                     onPressed: _editProfile,
//                     icon: const Icon(Icons.edit),
//                     label: const Text("Edit Profile"),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
//                   ),
//                   const Divider(height: 30),
//                   // Shipping Address
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Shipping Address",
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           address ?? "Not added",
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' as io; // For mobile
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'package:watchhub/addcart.dart';
import 'package:watchhub/home.dart';
import 'package:watchhub/search.dart'; // For web

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
   List<Map<String, dynamic>> cart = [];
    int _selectedIndex = 0;
  final supabase = Supabase.instance.client;
  String? profileUrl;
  String? name;
  String? email;
  String? phone;
  String? address;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    setState(() {
      email = user.email;
      name = response?['name'] ?? "User";
      phone = response?['phone'];
      address = response?['address'];
      profileUrl = response?['profile_url'];
    });
  }

  Future<void> _pickProfileImage() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    Uint8List? bytes;
    String fileName = "${user.id}.jpg";

    if (kIsWeb) {
      // ---------------- Web ----------------
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      await uploadInput.onChange.first;
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final file = files[0];
      fileName = "${user.id}_${file.name}";
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoadEnd.first;
      bytes = reader.result as Uint8List;
    } else {
      // ---------------- Mobile/Desktop ----------------
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      fileName = "${user.id}_${picked.name}";
      final file = io.File(picked.path);
      bytes = await file.readAsBytes();
    }

    setState(() => isUploading = true);

    try {
      // Upload file
      await supabase.storage
          .from('profile_pics')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL (ensure .data is used)
      final url = supabase.storage.from('profile_pics').getPublicUrl(fileName);
      if (url == null) throw 'Failed to get public URL';

      // Update profile table
      await supabase
          .from('profiles')
          .update({'profile_url': url})
          .eq('id', user.id);

      // Update UI
      setState(() => profileUrl = url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture uploaded!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _editProfile() {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    final addressController = TextEditingController(text: address);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "Shipping Address",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = supabase.auth.currentUser;
              if (user != null) {
                await supabase.from('profiles').upsert({
                  'id': user.id,
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'address': addressController.text,
                });
                setState(() {
                  name = nameController.text;
                  phone = phoneController.text;
                  address = addressController.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

return Scaffold(
  appBar: AppBar(
    title: const Text("Profile"),
    actions: [
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'Logout',
        onPressed: () async {
          await supabase.auth.signOut();
          // Optional: Navigate to login page
          // Navigator.pushReplacementNamed(context, '/login');

          // Clear local state
          setState(() {
            profileUrl = null;
            name = null;
            email = null;
            phone = null;
            address = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully')),
          );
        },
      ),
    ],
  ),
  body: Stack(
    children: [
      user == null
          ? const Center(child: Text("Please login to see your profile"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profileUrl != null && profileUrl!.isNotEmpty
                              ? NetworkImage(profileUrl!)
                              : const AssetImage("assets/profile.png") as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.teal,
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name ?? "User",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                  const Divider(height: 30),
                  // Shipping Address
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Shipping Address",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          address ?? "Not added",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      // ---------------- Loading Overlay ----------------
      if (isUploading)
        Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          ),
        ),
    ],
  ),
   // ✅ Fixed Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage(cart: cart)),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
        selectedItemColor: const Color.fromARGB(255, 0, 105, 95),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        "${cart.length}",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
);
}
}
