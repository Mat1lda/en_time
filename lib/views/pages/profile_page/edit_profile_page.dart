import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:en_time/database/services/user_services.dart'; // Import UserService đúng path

// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({Key? key}) : super(key: key);
//
//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }
//
// class _EditProfilePageState extends State<EditProfilePage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _birthdayController = TextEditingController(); // Controller ngày sinh
//
//   DateTime? _selectedBirthday;
//   String? _selectedGender;
//   bool _isLoading = true;
//   // Biến để lưu avatar tạm thời
//   File? _newAvatarFile;
//   //String? _newAvatarUrl;
//
//   final UserService _userService = UserService(); // Khởi tạo UserService
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     try {
//       final user = await _userService.getCurrentUser();
//       if (user != null) {
//         setState(() {
//           _nameController.text = user.fullName;
//           _emailController.text = user.email;
//           _selectedBirthday = user.birthday;
//           _selectedGender = user.gender;
//           if (user.birthday != null) {
//             _birthdayController.text = DateFormat('dd/MM/yyyy').format(user.birthday!);
//           }
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading user: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text('Chỉnh sửa thông tin'),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       backgroundColor: Colors.white,
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             _buildAvatar(),
//             const SizedBox(height: 30),
//             _buildTextField(label: 'Họ và tên', controller: _nameController, enabled: true),
//             const SizedBox(height: 20),
//             _buildTextField(label: 'Email', controller: _emailController, enabled: false),
//             const SizedBox(height: 20),
//             _buildBirthdayField(),
//             const SizedBox(height: 20),
//             _buildGenderDropdown(),
//             const SizedBox(height: 40),
//             _buildSaveButton(),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildAvatar() {
//   //   return Stack(
//   //     alignment: Alignment.bottomRight,
//   //     children: [
//   //       // CircleAvatar(
//   //       //   radius: 60,
//   //       //   backgroundColor: Colors.purple[100],
//   //       //   child: const Icon(Icons.person, size: 60, color: Colors.white),
//   //       // ),
//   //       StreamBuilder<DocumentSnapshot>(
//   //         stream: FirebaseFirestore.instance
//   //             .collection('users')
//   //             .doc(FirebaseAuth.instance.currentUser!.uid)
//   //             .snapshots(),
//   //         builder: (context, snapshot) {
//   //           if (!snapshot.hasData) {
//   //             return const CircleAvatar(radius: 60, backgroundColor: Colors.grey);
//   //           }
//   //           var userData = snapshot.data!.data() as Map<String, dynamic>;
//   //           String? avatarUrl = userData['avatarUrl'];
//   //
//   //           if (avatarUrl != null && avatarUrl.isNotEmpty) {
//   //             return CircleAvatar(
//   //               radius: 60,
//   //               backgroundImage: NetworkImage(avatarUrl),
//   //             );
//   //           } else {
//   //             return const CircleAvatar(
//   //               radius: 60,
//   //               backgroundColor: Colors.grey,
//   //               child: Icon(Icons.person, size: 60, color: Colors.white),
//   //             );
//   //           }
//   //         },
//   //       ),
//   //       Positioned(
//   //         bottom: 0,
//   //         right: 0,
//   //         child: Container(
//   //           decoration: BoxDecoration(
//   //             color: Colors.white,
//   //             shape: BoxShape.circle,
//   //             boxShadow: [
//   //               BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
//   //             ],
//   //           ),
//   //           child: IconButton(
//   //             icon: const Icon(Icons.camera_alt, color: Colors.purple, size: 20),
//   //             onPressed: () async {
//   //               // TODO: chọn ảnh mới
//   //               final newAvatarUrl = await _userService.pickAndUploadAvatar();
//   //               if (newAvatarUrl != null) {
//   //                 setState(() {}); // Reload lại giao diện nếu cần
//   //                 ScaffoldMessenger.of(context).showSnackBar(
//   //                   const SnackBar(content: Text('Cập nhật avatar thành công!')),
//   //                 );
//   //               }
//   //             },
//   //           ),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }
//
// // Hiển thị avatar và chọn ảnh mới
//   Widget _buildAvatar() {
//     return Stack(
//       alignment: Alignment.bottomRight,
//       children: [
//         // Hiển thị ảnh cũ từ Firestore
//         StreamBuilder<DocumentSnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('users')
//               .doc(FirebaseAuth.instance.currentUser!.uid)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const CircleAvatar(radius: 60, backgroundColor: Colors.grey);
//             }
//             var userData = snapshot.data!.data() as Map<String, dynamic>;
//             String? avatarUrl = userData['avatarUrl'];
//
//             return CircleAvatar(
//               radius: 60,
//               backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
//                   ? NetworkImage(avatarUrl) // Hiển thị avatar cũ từ Firestore
//                   : null,
//               child: avatarUrl == null
//                   ? const Icon(Icons.person, size: 60, color: Colors.white)
//                   : null,
//             );
//           },
//         ),
//         Positioned(
//           bottom: 0,
//           right: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
//               ],
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.camera_alt, color: Colors.purple, size: 20),
//               onPressed: () async {
//                 // Chọn ảnh từ thư viện
//                 final picker = ImagePicker();
//                 final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//                 if (pickedFile != null) {
//                   setState(() {
//                     _newAvatarFile = File(pickedFile.path); // Lưu ảnh vào biến tạm thời
//                   });
//                 }
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//
//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     bool enabled = true,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           enabled: enabled,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Widget _buildBirthdayField() {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       const Text('Ngày sinh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//   //       const SizedBox(height: 8),
//   //       TextFormField(
//   //         controller: _birthdayController,
//   //         readOnly: false,
//   //         decoration: InputDecoration(
//   //           hintText: 'dd/MM/yyyy',
//   //           filled: true,
//   //           fillColor: Colors.grey[100],
//   //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//   //           border: OutlineInputBorder(
//   //             borderRadius: BorderRadius.circular(12),
//   //             borderSide: BorderSide.none,
//   //           ),
//   //           suffixIcon: IconButton(
//   //             icon: const Icon(Icons.calendar_today),
//   //             onPressed: () async {
//   //               DateTime initialDate = _selectedBirthday ?? DateTime(2000, 1, 1);
//   //               DateTime? pickedDate = await showDatePicker(
//   //                 context: context,
//   //                 initialDate: initialDate,
//   //                 firstDate: DateTime(1900),
//   //                 lastDate: DateTime.now(),
//   //               );
//   //               if (pickedDate != null) {
//   //                 setState(() {
//   //                   _selectedBirthday = pickedDate;
//   //                   _birthdayController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
//   //                 });
//   //               }
//   //             },
//   //           ),
//   //         ),
//   //         keyboardType: TextInputType.datetime,
//   //         onChanged: (value) {
//   //           try {
//   //             final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(value);
//   //             setState(() {
//   //               _selectedBirthday = parsedDate;
//   //             });
//   //           } catch (e) {
//   //             // Nếu nhập sai định dạng thì không làm gì
//   //           }
//   //         },
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   Widget _buildBirthdayField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Ngày sinh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _birthdayController,
//           readOnly: false,
//           decoration: InputDecoration(
//             hintText: 'dd/MM/yyyy',
//             filled: true,
//             fillColor: Colors.grey[100],
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(30),
//               borderSide: const BorderSide(color: Colors.black, width: 1),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(30),
//               borderSide: const BorderSide(color: Colors.black, width: 1),
//             ),
//             suffixIcon: IconButton(
//               icon: const Icon(Icons.calendar_today),
//               onPressed: () async {
//                 DateTime initialDate = _selectedBirthday ?? DateTime(2000, 1, 1);
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: initialDate,
//                   firstDate: DateTime(1900),
//                   lastDate: DateTime.now(),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     _selectedBirthday = pickedDate;
//                     _birthdayController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
//                   });
//                 }
//               },
//             ),
//           ),
//           keyboardType: TextInputType.datetime,
//           onChanged: (value) {
//             try {
//               final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(value);
//               setState(() {
//                 _selectedBirthday = parsedDate;
//               });
//             } catch (e) {
//               // Không làm gì khi nhập sai định dạng
//             }
//           },
//         )
//
//       ],
//     );
//   }
//
//
//   // Widget _buildGenderDropdown() {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       const Text('Giới tính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//   //       const SizedBox(height: 8),
//   //       DropdownButtonFormField<String>(
//   //         value: _selectedGender,
//   //         isDense: true, // 👉 Thêm dòng này: Làm dropdown nhỏ gọn
//   //         style: const TextStyle(fontSize: 16, color: Colors.black), // 👉 Để font chữ đồng bộ TextField
//   //         decoration: InputDecoration(
//   //           isDense: true, // 👉 Làm Input nhỏ gọn
//   //           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // 👉 Padding giống TextField
//   //           border: OutlineInputBorder(
//   //             borderRadius: BorderRadius.circular(12),
//   //             borderSide: BorderSide.none,
//   //           ),
//   //         ),
//   //         hint: const Text('Chọn giới tính', style: TextStyle(fontSize: 16)),
//   //         items: ['Nam', 'Nữ', 'Khác'].map((gender) {
//   //           return DropdownMenuItem<String>(
//   //             value: gender,
//   //             child: Text(gender),
//   //           );
//   //         }).toList(),
//   //         onChanged: (value) {
//   //           setState(() {
//   //             _selectedGender = value;
//   //           });
//   //         },
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   Widget _buildGenderDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Giới tính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: _selectedGender,
//           isDense: true,
//           icon: const Icon(Icons.keyboard_arrow_down_rounded),
//           style: const TextStyle(fontSize: 16, color: Colors.black),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.grey[100],
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             enabledBorder: OutlineInputBorder( // 👉 Viền khi bình thường
//               borderRadius: BorderRadius.circular(30), // 👉 Bo tròn mạnh tay
//               borderSide: const BorderSide(color: Colors.black, width: 1), // Viền đen mảnh
//             ),
//             focusedBorder: OutlineInputBorder( // 👉 Viền khi focus
//               borderRadius: BorderRadius.circular(30),
//               borderSide: const BorderSide(color: Colors.black, width: 1),
//             ),
//           ),
//           dropdownColor: Colors.grey[100],
//           hint: const Text('Chọn giới tính', style: TextStyle(fontSize: 16)),
//           items: ['Nam', 'Nữ', 'Khác'].map((gender) {
//             return DropdownMenuItem<String>(
//               value: gender,
//               child: Text(gender),
//             );
//           }).toList(),
//           onChanged: (value) {
//             setState(() {
//               _selectedGender = value;
//             });
//           },
//         ),
//       ],
//     );
//   }
//
//
//
//
//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _saveProfile,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.purple,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: const Text(
//           'Lưu thay đổi',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _saveProfile() async {
//     String newName = _nameController.text.trim();
//     if (newName.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Tên không được để trống')),
//       );
//       return;
//     }
//
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const Center(child: CircularProgressIndicator()),
//       );
//
//       // Upload avatar nếu có
//       String? avatarUrl;
//       if (_newAvatarFile != null) {
//         avatarUrl = await _userService.uploadAvatar(_newAvatarFile!);
//       }
//
//       await _userService.updateUser(
//         fullName: newName,
//         birthday: _selectedBirthday,
//         gender: _selectedGender,
//         avatarUrl: avatarUrl,  // Chỉ cập nhật avatarUrl nếu có thay đổi
//       );
//
//       if (context.mounted) {
//         Navigator.pop(context); // Đóng loading
//         Navigator.pop(context); // Quay về màn ProfilePage
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Cập nhật thành công')),
//         );
//       }
//     } catch (e) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Đã có lỗi xảy ra: $e')),
//       );
//     }
//   }
// }


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController(); // Controller ngày sinh

  DateTime? _selectedBirthday;
  String? _selectedGender;
  bool _isLoading = true;

  // Biến để lưu avatar tạm thời
  File? _newAvatarFile;
  String? _currentAvatarUrl; // Để lưu URL avatar hiện tại

  final UserService _userService = UserService(); // Khởi tạo UserService

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      if (user != null) {
        setState(() {
          _nameController.text = user.fullName;
          _emailController.text = user.email;
          _selectedBirthday = user.birthday;
          _selectedGender = user.gender;
          _currentAvatarUrl = user.avatarUrl; // Lưu URL avatar hiện tại
          if (user.birthday != null) {
            _birthdayController.text = DateFormat('dd/MM/yyyy').format(user.birthday!);
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Chỉnh sửa thông tin",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAvatar(),  // Hiển thị avatar
            const SizedBox(height: 30),
            _buildTextField(label: 'Họ và tên', controller: _nameController, enabled: true),
            const SizedBox(height: 20),
            _buildTextField(label: 'Email', controller: _emailController, enabled: false),
            const SizedBox(height: 20),
            _buildBirthdayField(),
            const SizedBox(height: 20),
            _buildGenderDropdown(),
            const SizedBox(height: 40),
            _buildSaveButton(), // Lưu thay đổi
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Hiển thị avatar và chọn ảnh mới
  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Hiển thị ảnh cũ từ Firestore hoặc ảnh mới đã chọn
        CircleAvatar(
          radius: 60,
          backgroundImage: _newAvatarFile != null
              ? FileImage(_newAvatarFile!) // Hiển thị ảnh mới đã chọn
              : _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
              ? NetworkImage(_currentAvatarUrl!) as ImageProvider
              : const AssetImage('assets/images/ArrowLeft.png'), // Hiển thị avatar cũ từ Firestore
          child: _newAvatarFile == null && _currentAvatarUrl == null
              ? const Icon(Icons.person, size: 60, color: Colors.white)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.purple, size: 20),
              onPressed: () async {
                // Chọn ảnh từ thư viện
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _newAvatarFile = File(pickedFile.path); // Lưu ảnh vào biến tạm thời
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthdayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ngày sinh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _birthdayController,
          readOnly: false,
          decoration: InputDecoration(
            hintText: 'dd/MM/yyyy',
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime initialDate = _selectedBirthday ?? DateTime(2000, 1, 1);
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedBirthday = pickedDate;
                    _birthdayController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                  });
                }
              },
            ),
          ),
          keyboardType: TextInputType.datetime,
          onChanged: (value) {
            try {
              final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(value);
              setState(() {
                _selectedBirthday = parsedDate;
              });
            } catch (e) {
              // Không làm gì khi nhập sai định dạng
            }
          },
        )
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Giới tính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: const TextStyle(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder( // 👉 Viền khi bình thường
              borderRadius: BorderRadius.circular(30), // 👉 Bo tròn mạnh tay
              borderSide: const BorderSide(color: Colors.black, width: 1), // Viền đen mảnh
            ),
            focusedBorder: OutlineInputBorder( // 👉 Viền khi focus
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
          dropdownColor: Colors.grey[100],
          hint: const Text('Chọn giới tính', style: TextStyle(fontSize: 16)),
          items: ['Nam', 'Nữ', 'Khác'].map((gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Lưu thay đổi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    String newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên không được để trống')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Upload avatar nếu có
      String? avatarUrl;
      if (_newAvatarFile != null) {
        avatarUrl = await _userService.uploadAvatar(_newAvatarFile!); // Upload avatar
      }

      await _userService.updateUser(
        fullName: newName,
        birthday: _selectedBirthday,
        gender: _selectedGender,
        avatarUrl: avatarUrl, // Chỉ cập nhật avatarUrl nếu có thay đổi
      );

      if (context.mounted) {
        Navigator.pop(context); // Đóng loading
        Navigator.pop(context); // Quay về màn ProfilePage
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã có lỗi xảy ra: $e')),
      );
    }
  }
}
