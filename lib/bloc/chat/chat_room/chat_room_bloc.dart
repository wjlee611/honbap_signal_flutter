import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honbap_signal_flutter/bloc/chat/chat_room/chat_room_event.dart';
import 'package:honbap_signal_flutter/bloc/chat/chat_room/chat_room_state.dart';
import 'package:honbap_signal_flutter/repository/honbab/chat/chat_room_repository.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final ChatRoomRepository _chatRoomRepository;
  final String roomId;

  ChatRoomBloc(this._chatRoomRepository, this.roomId)
      : super(const ChatRoomState(status: ChatRoomStatus.init)) {
    on<ChatRoomGetEvent>(_chatRoomGetEventHandler);
  }

  Future<void> _chatRoomGetEventHandler(
    ChatRoomGetEvent event,
    Emitter<ChatRoomState> emit,
  ) async {
    emit(state.copyWith(status: ChatRoomStatus.loading));

    try {
      var chatResults = await _chatRoomRepository.getChats(
        jwt: event.jwt,
        roomId: roomId,
      );

      emit(state.copyWith(
        status: ChatRoomStatus.success,
        chats: chatResults,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatRoomStatus.error,
        message: e.toString(),
      ));
    }
  }
}
