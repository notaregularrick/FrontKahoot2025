abstract class NotificationsRepository {
  Future<void> registerDevice(String token);
  Future<void> unregisterDevice(String token);
}

