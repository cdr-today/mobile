import './conf.dart';
import './utils.dart';
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';

// ------------ bloc -------------
class EditBloc extends Bloc<EditEvent, EditState> {
  @override
  EditState get initialState => Empty();

  @override
  Stream<EditState> mapEventToState(EditEvent event) async* {
    if (event is CompletedEdit) {
      var mail = await getString('mail');
      Map data = {
        'title': event.title,
        'content': event.content
      };
      
      var res = await http.post(
        "${conf['url']}/${mail}/publish",
        body: json.encode(data),
      );
      if (res.statusCode == 200) {
        yield PublishSucceed();
      } else {
        yield PublishFailed();
      }
    } else if (event is UpdateEdit) {
      var mail = await getString('mail');
      Map data = {
        'id': event.id,
        'title': event.title,
        'content': event.content
      };
      
      var res = await http.post(
        "${conf['url']}/${mail}/article/update",
        body: json.encode(data),
      );
      if (res.statusCode == 200) {
        yield UpdateSucceed();
        yield Empty();
      } else {
        yield UpdateFailed();
      }
      
    } else if (event is DeleteEdit) {
      var mail = await getString('mail');
      Map data = {
        'id': event.id,
      };
      
      var res = await http.post(
        "${conf['url']}/${mail}/article/delete",
        body: json.encode(data),
      );
      if (res.statusCode == 200) {
        yield DeleteSucceed();
        yield Empty();
      } else {
        yield DeleteFailed();
      }
    }
    return;
  }
}

// ------------- state ------------
abstract class EditState extends Equatable {
  EditState([List props = const []]) : super(props);
}

class Empty extends EditState {
  @override
  String toString() => 'Empty';
}

class PrePublish extends EditState {
  @override
  String toString() => 'PrePublish';
}

class DeleteSucceed extends EditState {
  @override
  String toString() => 'DeleteSucceed';
}

class DeleteFailed extends EditState {
  @override
  String toString() => 'DeleteFailed';
}

class UpdateSucceed extends EditState {
  @override
  String toString() => 'UpdateSucceed';
}

class UpdateFailed extends EditState {
  @override
  String toString() => 'UpdateFailed';
}

class PublishSucceed extends EditState {
  @override
  String toString() => 'PublishSucceed';
}

class PublishFailed extends EditState {
  @override
  String toString() => 'PublishFailed';
}

// ------------- events -------------
abstract class EditEvent extends Equatable {}

class UpdateEdit extends EditEvent {
  final String id;
  final String title;
  final String content;
  UpdateEdit({ this.id, this.title, this.content });
}

class CompletedEdit extends EditEvent {
  final String title;
  final String content;
  CompletedEdit({ this.title, this.content });
}

class DeleteEdit extends EditEvent {
  final String id;
  DeleteEdit({ this.id });
}
