import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liên hệ'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Nếu bạn có bất kỳ câu hỏi, góp ý hoặc yêu cầu hỗ trợ, vui lòng liên hệ với chúng tôi qua:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text('• Email: over2505@gmail.com', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('• Số điện thoại: +84 967726885', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('• Địa chỉ: Ngõ 33 Đ. Đại Mỗ, Đai Mễ, Nam Từ Liêm, Hà Nội, Việt Nam', style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            Text(
              'Chúng tôi sẽ phản hồi bạn trong vòng 24 giờ làm việc.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
