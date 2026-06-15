import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String text;

  SendMessage(this.text);

  @override
  List<Object?> get props => [text];
}
