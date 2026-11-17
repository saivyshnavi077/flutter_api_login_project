import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Users API',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF5F3FF),
      ),
      home: const UsersPage(),
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final String apiUrl = 'https://jsonplaceholder.typicode.com/users';

  List<Map<String, dynamic>> users = [];
  bool isLoading = false;

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  final phoneController = TextEditingController();
  final websiteController = TextEditingController();

  final streetController = TextEditingController();
  final suiteController = TextEditingController();
  final cityController = TextEditingController();
  final zipcodeController = TextEditingController();

  final latController = TextEditingController();
  final lngController = TextEditingController();
  final companyNameController = TextEditingController();
  final catchPhraseController = TextEditingController();
  final bsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // GET API
  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          users = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        showMessage('Failed to fetch users');
      }
    } catch (e) {
      showMessage('Error fetching users: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // POST API
  Future<void> addUser() async {
    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty) {
      showMessage('Please fill in all fields');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'name': name, 'username': username, 'email': email}),
      );

      if (response.statusCode == 201) {
        final newUser = Map<String, dynamic>.from(jsonDecode(response.body));

        if (!mounted) return;

        setState(() {
          users.insert(0, newUser);
        });

        Navigator.pop(context);
        clearFields();
        showMessage('User added successfully');
      } else {
        showMessage('Failed to add user');
      }
    } catch (e) {
      showMessage('Error adding user: $e');
    }
  }

  // PUT API
  Future<void> updateUser(int id) async {
    final updatedData = {
      'id': id,
      'name': nameController.text.trim(),
      'username': usernameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'website': websiteController.text.trim(),

      'address': {
        'street': streetController.text.trim(),
        'suite': suiteController.text.trim(),
        'city': cityController.text.trim(),
        'zipcode': zipcodeController.text.trim(),
        'geo': {
          'lat': latController.text.trim(),
          'lng': lngController.text.trim(),
        },
      },

      'company': {
        'name': companyNameController.text.trim(),
        'catchPhrase': catchPhraseController.text.trim(),
        'bs': bsController.text.trim(),
      },
    };

    if (updatedData['name'] == '' ||
        updatedData['username'] == '' ||
        updatedData['email'] == '') {
      showMessage('Please fill in Name, Username and Email');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          final index = users.indexWhere((user) => user['id'] == id);

          if (index != -1) {
            users[index] = updatedData;
          }
        });

        Navigator.pop(context);
        clearFields();
        showMessage('User updated successfully');
      } else {
        showMessage('Failed to update user');
      }
    } catch (e) {
      showMessage('Error updating user: $e');
    }
  }

  // DELETE API
  Future<void> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;

        setState(() {
          users.removeWhere((user) => user['id'] == id);
        });

        showMessage('User deleted successfully');
      } else {
        showMessage('Failed to delete user');
      }
    } catch (e) {
      showMessage('Error deleting user: $e');
    }
  }

  void clearFields() {
    nameController.clear();
    usernameController.clear();
    emailController.clear();

    phoneController.clear();
    websiteController.clear();

    streetController.clear();
    suiteController.clear();
    cityController.clear();
    zipcodeController.clear();

    latController.clear();
    lngController.clear();

    companyNameController.clear();
    catchPhraseController.clear();
    bsController.clear();
  }

  // ADD / EDIT DIALOG
  void showUserDialog({Map<String, dynamic>? user}) {
    final isEditing = user != null;

    final address = user?['address'] ?? {};
    final geo = address['geo'] ?? {};
    final company = user?['company'] ?? {};

    nameController.text = user?['name']?.toString() ?? '';
    usernameController.text = user?['username']?.toString() ?? '';
    emailController.text = user?['email']?.toString() ?? '';

    phoneController.text = user?['phone']?.toString() ?? '';
    websiteController.text = user?['website']?.toString() ?? '';

    streetController.text = address['street']?.toString() ?? '';
    suiteController.text = address['suite']?.toString() ?? '';
    cityController.text = address['city']?.toString() ?? '';
    zipcodeController.text = address['zipcode']?.toString() ?? '';

    latController.text = geo['lat']?.toString() ?? '';
    lngController.text = geo['lng']?.toString() ?? '';

    companyNameController.text = company['name']?.toString() ?? '';
    catchPhraseController.text = company['catchPhrase']?.toString() ?? '';
    bsController.text = company['bs']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit User Details' : 'Add New User'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildField(nameController, 'Name'),
                  buildField(usernameController, 'Username'),
                  buildField(emailController, 'Email'),
                  buildField(phoneController, 'Phone'),
                  buildField(websiteController, 'Website'),

                  Divider(height: 30),
                  Text(
                    'Address Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  buildField(streetController, 'Street'),
                  buildField(suiteController, 'Suite'),
                  buildField(cityController, 'City'),
                  buildField(zipcodeController, 'Zipcode'),
                  buildField(latController, 'Latitude'),
                  buildField(lngController, 'Longitude'),

                  Divider(height: 30),
                  Text(
                    'Company Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  buildField(companyNameController, 'Company Name'),
                  buildField(catchPhraseController, 'Catch Phrase'),
                  buildField(bsController, 'Business'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                clearFields();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  updateUser(user['id'] as int);
                } else {
                  addUser();
                }
              },
              child: Text(isEditing ? 'Update' : 'Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();

    phoneController.dispose();
    websiteController.dispose();

    streetController.dispose();
    suiteController.dispose();
    cityController.dispose();
    zipcodeController.dispose();

    latController.dispose();
    lngController.dispose();

    companyNameController.dispose();
    catchPhraseController.dispose();
    bsController.dispose();
    super.dispose();
  }

  // USER DETAIL ROW
  Widget detailRow(IconData icon, String title, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SECTION TITLE
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  // USER CARD
  Widget userCard(Map<String, dynamic> user, int index) {
    final address = user['address'] ?? {};
    final geo = address['geo'] ?? {};
    final company = user['company'] ?? {};

    return Card(
      elevation: 3,
      shadowColor: Colors.grey.shade200,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARD HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF35245B),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '@${user['username'] ?? ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      showUserDialog(user: user);
                    } else if (value == 'delete') {
                      deleteUser(user['id'] as int);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // CARD DETAILS
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle('CONTACT INFORMATION'),

                detailRow(
                  Icons.email_outlined,
                  'Email',
                  user['email']?.toString() ?? '',
                ),
                detailRow(
                  Icons.phone_outlined,
                  'Phone',
                  user['phone']?.toString() ?? '',
                ),
                detailRow(
                  Icons.language,
                  'Website',
                  user['website']?.toString() ?? '',
                ),

                sectionTitle('ADDRESS'),

                detailRow(
                  Icons.location_on_outlined,
                  'Street',
                  '${address['street'] ?? ''}, ${address['suite'] ?? ''}',
                ),
                detailRow(
                  Icons.location_city,
                  'City',
                  address['city']?.toString() ?? '',
                ),
                detailRow(
                  Icons.markunread_mailbox_outlined,
                  'Zipcode',
                  address['zipcode']?.toString() ?? '',
                ),
                detailRow(
                  Icons.my_location,
                  'Latitude',
                  geo['lat']?.toString() ?? '',
                ),
                detailRow(
                  Icons.my_location,
                  'Longitude',
                  geo['lng']?.toString() ?? '',
                ),

                sectionTitle('COMPANY DETAILS'),

                detailRow(
                  Icons.business_outlined,
                  'Company',
                  company['name']?.toString() ?? '',
                ),
                detailRow(
                  Icons.lightbulb_outline,
                  'Catch Phrase',
                  company['catchPhrase']?.toString() ?? '',
                ),
                detailRow(
                  Icons.work_outline,
                  'Business',
                  company['bs']?.toString() ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Users',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Manage your user information',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: fetchUsers,
                    icon: Icon(Icons.refresh, color: Colors.white, size: 28),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            // USER COUNT
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Row(
                children: [
                  Text(
                    'User List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${users.length} Users',
                      style:TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // USER LIST
            Expanded(
              child: isLoading && users.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : users.isEmpty
                  ? Center(child: Text('No users available'))
                  : RefreshIndicator(
                      onRefresh: fetchUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return userCard(users[index], index);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),

      // ADD USER BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showUserDialog(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon:Icon(Icons.add),
        label:Text('Add User'),
      ),
    );
  }
}
