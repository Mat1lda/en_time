import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chính sách bảo mật'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Chúng tôi cam kết bảo vệ quyền riêng tư và thông tin cá nhân của bạn.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text('- Chúng tôi thu thập thông tin nhằm mục đích cung cấp dịch vụ tốt hơn.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('- Thông tin cá nhân của bạn sẽ được lưu trữ an toàn và không chia sẻ với bên thứ ba nếu không có sự đồng ý của bạn.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('- Bạn có quyền yêu cầu truy cập, chỉnh sửa hoặc xóa dữ liệu cá nhân của mình.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 30),
              Text(
                'Mọi thắc mắc liên quan đến chính sách bảo mật, vui lòng liên hệ với chúng tôi.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
