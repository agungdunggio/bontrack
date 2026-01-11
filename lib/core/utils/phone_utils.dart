extension StringExtension on String {
  String toFormattedPhone() {
    var phone = replaceAll(RegExp(r'[^\d+]'), '');
    
    if (phone.startsWith('0')) {
      phone = '+62${phone.substring(1)}';
    } else if (phone.startsWith('62') && !phone.startsWith('+')) {
      phone = '+$phone';
    } else if (!phone.startsWith('+')) {
      phone = '+62$phone';
    }
    return phone;
  }
}