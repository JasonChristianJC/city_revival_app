class AppConstants {
  // Church Information
  static const String churchName = 'City Revival AG Church';
  static const String churchNameTa = 'சிட்டி ரிவைவல் ஏஜி திருச்சபை';
  static const String churchLocation = 'Tiruchirappalli, Tamil Nadu, India';
  static const String churchAddress =
      'City Revival AG Church, Near TVS Tollgate / Cantonment, Tiruchirappalli - 620020, Tamil Nadu, India';
  static const String churchPhone = '+91 94431 00000';
  static const String churchEmail = 'contact@cityrevivalag.org';
  static const String seniorPastor = 'Rev. Dr. Jerry Daniel';
  static const String seniorPastorTa = 'ரெவ். டாக்டர் ஜெர்ரி டேனியல்';
  static const String churchTagline =
      'A House of Prayer for All Nations • Revival in Trichy & Beyond';

  // Supabase Configuration
  static const String supabaseUrl = 'https://fycmdyxllutinvfwdljy.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_b8pvAS7D5h4mTVVjyiA-rQ_vzzpOivN';

  // Storage Buckets
  static const String bucketMagazinePdfs = 'magazine-pdfs';
  static const String bucketGalleryImages = 'gallery-images';
  static const String bucketMissionaries = 'missionaries';

  // Sunday Service Timings (IST)
  static const List<ServiceSchedule> sundayServices = [
    ServiceSchedule(
      name: '1st Tamil Service',
      nameTa: 'முதலாம் தமிழ் ஆராதனை',
      time: '6:00 AM',
      hour: 6,
      minute: 0,
    ),
    ServiceSchedule(
      name: '2nd Tamil Service',
      nameTa: 'இரண்டாம் தமிழ் ஆராதனை',
      time: '8:30 AM',
      hour: 8,
      minute: 30,
    ),
    ServiceSchedule(
      name: 'English & Youth Service',
      nameTa: 'ஆங்கிலம் & வாலிபர் ஆராதனை',
      time: '10:45 AM',
      hour: 10,
      minute: 45,
    ),
  ];

  // UPI & Banking Details
  static const String upiId = 'cityrevivalag@sbi';
  static const String upiPayeeName = 'CITY REVIVAL AG CHURCH';
  static const String bankName = 'State Bank of India';
  static const String accountHolder = 'CITY REVIVAL AG CHURCH';
  static const String accountNumber = '38920100001234';
  static const String ifscCode = 'SBIN0001234';
  static const String branchName = 'Cantonment, Tiruchirappalli';

  // Vision 2035 Church Building Fund
  static const String vision2035Title = 'Vision 2035 Church Building Fund';
  static const String vision2035Subtitle =
      'Raising a 5,000-seat sanctuary for the glory of God in Tiruchirappalli';
  static const double vision2035TargetAmount = 100000000; // 10 Crores INR
  static const double vision2035CollectedAmount = 43500000; // 4.35 Crores INR

  // Social & Media Links
  static const String youtubeChannelUrl =
      'https://www.youtube.com/@cityrevivalagchurch';
  static const String whatsappContact = '919443100000';
}

class ServiceSchedule {
  final String name;
  final String nameTa;
  final String time;
  final int hour;
  final int minute;

  const ServiceSchedule({
    required this.name,
    required this.nameTa,
    required this.time,
    required this.hour,
    required this.minute,
  });
}
