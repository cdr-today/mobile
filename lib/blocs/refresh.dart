import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';
import 'package:cdr_today/blocs/post.dart';
import 'package:cdr_today/blocs/reddit.dart';
import 'package:cdr_today/blocs/_author.dart';
import 'package:cdr_today/blocs/community.dart';

class RefreshBloc extends Bloc<RefreshEvent, RefreshState> {
  final PostBloc p;
  final RedditBloc r;
  final CommunityBloc c;
  final AuthorPostBloc a;
  
  RefreshBloc({ this.p, this.c, this.r, this.a }) {
    p.state.listen((state) {
        if (state is Posts) {
          if (state.refresh == 0) return;
          this.dispatch(PostRefresh(refresh: false));
        }
    });
    
    c.state.listen((state) {
        if (state is Communities) {
          if (state.refresh == 0) return;
          this.dispatch(CommunityRefresh(refresh: false));
        }
    });

    r.state.listen((state) {
        if (state is Reddits) {
          if (state.refresh == 0) return;
          this.dispatch(RedditRefresh(refresh: false));
        }
    });

    a.state.listen((state) {
        if (state is AuthorPosts) {
          if (state.refresh == 0) return;
          this.dispatch(Refresh(author: false));
        }
    });
  }
  
  @override
  Stream<RefreshState> transform(
    Stream<RefreshEvent> events,
    Stream<RefreshState> Function(RefreshEvent event) next,
  ) {
    return super.transform(
      (events as Observable<RefreshEvent>).debounceTime(
        Duration(milliseconds: 500),
      ), next,
    );
  }
  
  @override
  RefreshState get initialState => Refresher(
    edit: false,
    post: false,
    author: false,
    reddit: false,
    profile: false,
    community: false,
  );

  @override
  Stream<RefreshState> mapEventToState(RefreshEvent event) async* {
    if (event is PostRefresh) {
      yield (currentState as Refresher).copyWith(
        post: event.refresh ?? (currentState as Refresher).post
      );
    } else if (event is CommunityRefresh) {
      yield (currentState as Refresher).copyWith(
        community: event.refresh ?? (currentState as Refresher).community
      );
    } else if (event is RedditRefresh) {
      yield (currentState as Refresher).copyWith(
        reddit: event.refresh ?? (currentState as Refresher).reddit
      );
    } else if (event is Refresh) {
      yield (currentState as Refresher).copyWith(
        edit: event.edit ?? (currentState as Refresher).edit,
        author: event.author ?? (currentState as Refresher).author,
        profile: event.profile ?? (currentState as Refresher).profile,
      );
    }
    return;
  }
}

// -------------- states ------------------
abstract class RefreshState extends Equatable {
  RefreshState([List props = const []]) : super(props);
}

class Refresher extends RefreshState {
  final bool edit;
  final bool post;
  final bool author;
  final bool reddit;
  final bool profile;
  final bool community;
  Refresher({
      this.edit,
      this.post,
      this.author,
      this.reddit,
      this.profile,
      this.community
  }) : super([ edit, post, reddit, profile, community, author ]);

  Refresher copyWith({
      bool edit, bool post, bool community, bool reddit, bool profile, bool author
  }) {
    return Refresher(
      edit: edit ?? this.edit,
      post: post ?? this.post,
      author: author ?? this.author,
      reddit: reddit ?? this.reddit,
      profile: profile ?? this.profile,
      community: community ?? this.community
    );
  }
}

// -------------- events ----------------
abstract class RefreshEvent extends Equatable {}

class Refresh extends RefreshEvent {
  final bool edit;
  final bool author;
  final bool profile;
  Refresh({ this.edit, this.author, this.profile });

  @override
  String toString() => 'Refresh';
}

class PostRefresh extends RefreshEvent {
  final bool refresh;
  PostRefresh({ this.refresh = true });
  @override
  String toString() => 'PostRefresh';
}

class CommunityRefresh extends RefreshEvent {
  final bool refresh;
  CommunityRefresh({ this.refresh = true });
  @override
  String toString() => 'CommunityRefresh';
}

class RedditRefresh extends RefreshEvent {
  final bool refresh;
  RedditRefresh({ this.refresh = true });
  @override
  String toString() => 'RedditRefresh';
}
