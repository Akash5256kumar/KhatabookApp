/// User and business info returned by the /api/v1/home/ endpoint.
class HomeUserInfo {
  const HomeUserInfo({
    required this.fullName,
    required this.businessName,
    required this.businessLocation,
    required this.unreadNotifications,
    this.topCustomerId,
    this.topCustomerName,
    this.topCustomerPending,
  });

  final String fullName;
  final String businessName;
  final String businessLocation;
  final int unreadNotifications;

  /// Top customer by outstanding pending amount (may be absent).
  final String? topCustomerId;
  final String? topCustomerName;
  final double? topCustomerPending;

  static const HomeUserInfo empty = HomeUserInfo(
    fullName: '',
    businessName: '',
    businessLocation: '',
    unreadNotifications: 0,
  );
}
