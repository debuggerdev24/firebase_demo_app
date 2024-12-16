import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test_app/providers/auth_provider.dart';
import 'package:firebase_test_app/providers/profile_provider.dart';
import 'package:firebase_test_app/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthenticationProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (_) => false,
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: profileProvider.userProfileStream(
          context.read<AuthenticationProvider>().currentUser?.uid ?? '',
        ),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            context.read<ProfileProvider>().addProfile(
                  context.read<AuthenticationProvider>().currentUser?.uid ?? '',
                );
          }

          final userData = snapshot.data!.data()!;

          final firstNameController =
              TextEditingController(text: userData['firstName'] ?? "");
          final lastNameController =
              TextEditingController(text: userData['lastName'] ?? "");
          final dobController =
              TextEditingController(text: userData['dob'] ?? "");
          final locationController =
              TextEditingController(text: userData['currentLocation'] ?? "");

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                        labelText: "First Name", border: OutlineInputBorder()),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                        labelText: "Last Name", border: OutlineInputBorder()),
                  ),
                  TextField(
                    controller: dobController,
                    decoration: InputDecoration(
                        labelText: "Date of Birth",
                        border: OutlineInputBorder()),
                  ),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                        labelText: "Current Location",
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await profileProvider.updateProfile(
                            uid: context
                                    .read<AuthenticationProvider>()
                                    .currentUser
                                    ?.uid ??
                                '',
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            dob: dobController.text,
                            currentLocation: locationController.text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Profile updated successfully!")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Failed to update profile: $e")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Update Profile"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
