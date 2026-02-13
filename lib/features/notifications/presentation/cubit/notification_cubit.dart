import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finalproject/features/notifications/domain/entities/notification.dart';

class NotificationState {
  final List<AppNotification> notifications;
  NotificationState(this.notifications);
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationState([]));

  void addNotification(String title, String message) {
    final newNotification = AppNotification(
      id: DateTime.now().toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );
    emit(NotificationState([newNotification, ...state.notifications]));
  }

  void markAsRead(String id) {
    final updatedList = state.notifications.map((n) {
      if (n.id == id) {
        return AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          timestamp: n.timestamp,
          isRead: true,
        );
      }
      return n;
    }).toList();
    emit(NotificationState(updatedList));
  }
}
