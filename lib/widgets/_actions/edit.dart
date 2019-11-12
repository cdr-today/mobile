import 'dart:convert';
// import 'dart:io';
import 'package:zefyr/zefyr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cdr_today/x/store.dart';
import 'package:cdr_today/blocs/user.dart';
import 'package:cdr_today/blocs/refresh.dart';
import 'package:cdr_today/blocs/reddit.dart';
import 'package:cdr_today/blocs/topic.dart';
import 'package:cdr_today/blocs/community.dart';
import 'package:cdr_today/widgets/alerts.dart';
import 'package:cdr_today/widgets/buttons.dart';
import 'package:cdr_today/x/req.dart' as xReq;
import 'package:cdr_today/navigations/args.dart';
import 'package:screenshot/screenshot.dart';
// import 'package:esys_flutter_share/esys_flutter_share.dart';

class EditAction extends StatelessWidget {
  final BuildContext ctx;
  EditAction(this.ctx);
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        return CtNoRipple(
          icon: Icons.edit,
          size: 20.0,
          onTap: () async {
            Navigator.of(
              context, rootNavigator: true
            ).pushNamed(
              '/user/edit',
              arguments: ArticleArgs(community: (state as Communities).current)
            );
          }
        );
      }
    );
  }
}

class EditActionsProvider {
  final BuildContext context;
  final bool update;
  final ArticleArgs args;
  final VoidCallback toEdit;
  final VoidCallback toPreview;
  final ZefyrController zefyrController;
  final ScreenshotController screenshotController;
    
  EditActionsProvider(
    this.context, {
      this.args,
      this.screenshotController,
      this.zefyrController,
      this.toEdit,
      this.toPreview,
      this.update,
    }
  );

  Widget get more => More(
    args: args,
    update: update,
    toEdit: toEdit,
    zefyrController: zefyrController,
    screenshotController: screenshotController,
  );
  
  Widget get cancel => CtNoRipple(
    icon: Icons.highlight_off,
    onTap: toPreview
  );
}

class Post extends StatelessWidget {
  final bool update;
  final ArticleArgs args;
  final ZefyrController zefyrController;
  final VoidCallback toPreview;
  Post({ this.update, this.zefyrController, this.args, this.toPreview });

  @override
  Widget build(BuildContext context) {
    final RefreshBloc _bloc = BlocProvider.of<RefreshBloc>(context);
    final RedditBloc _rbloc = BlocProvider.of<RedditBloc>(context);
    final TopicBloc _tbloc = BlocProvider.of<TopicBloc>(context);
    
    return Builder(
      builder: (context) => CtNoRipple(
        icon: Icons.check,
        onTap: () async {
          final xReq.Requests r = await xReq.Requests.init();
          final String json = jsonEncode(zefyrController.document);

          FocusScope.of(context).requestFocus(FocusNode());
          if (!zefyrController.document.toPlainText().contains(RegExp(r'\S+'))) {
            info(context, '请填写文章内容');
            return;
          }

          if (update != true) {
            toPreview();
            return;
          }

          ///// refresh actions
          _bloc.dispatch(Refresh(edit: true));
          /////
          var res;
          res = await r.updateReddit(document: json, id: args.id);
          
          ///// stop refreshing actions
          _bloc.dispatch(Refresh(edit: false));
          ////

          if (res.statusCode != 200) {
            info(context, '更新失败，请重试');
            return;
          }

          // info(context, '更新成功');
          _bloc.dispatch(RedditRefresh(refresh: true));
          _rbloc.dispatch(FetchReddits(refresh: true));
          _tbloc.dispatch(UpdateTopic());
          
          if (toPreview != null) toPreview();
        }
      )
    );
  }

  static List<Widget> toList(BuildContext context, {
      bool update, ArticleArgs args, ZefyrController zefyrController,
  }) {
    return [Post(update: update, args: args, zefyrController: zefyrController)];
  }
}

class More extends StatelessWidget {
  final bool update;
  final ArticleArgs args;
  final VoidCallback toEdit;
  final ZefyrController zefyrController;
  final ScreenshotController screenshotController;
  More({
      this.args,
      this.update,
      this.toEdit,
      this.screenshotController,
      this.zefyrController,
  });
  
  @override
  build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserInited) {
          if (state.mail == args.mail || args.mail == null) {
            return EditActions(
              args: args,
              update: update,
              toEdit: toEdit,
              controller: screenshotController,
              zefyrController: zefyrController,
            );
          }
        }

        return SizedBox.shrink();
      }
    );
  }
}

class Publish extends StatelessWidget {
  final ArticleArgs args;
  final ZefyrController zefyrController;
  
  Publish({
      this.args,
      this.zefyrController
  });
  
  @override
  Widget build(BuildContext context) {
    final RefreshBloc _bloc = BlocProvider.of<RefreshBloc>(context);
    final RedditBloc _rbloc = BlocProvider.of<RedditBloc>(context);
    final TopicBloc _tbloc = BlocProvider.of<TopicBloc>(context);

    post() async {
      final xReq.Requests r = await xReq.Requests.init();
      final String json = jsonEncode(zefyrController.document);
      FocusScope.of(context).requestFocus(FocusNode());
      if (!zefyrController.document.toPlainText().contains(RegExp(r'\S+'))) {
        info(context, '请填写文章内容');
        return;
      }

      ///// refresh actions
      _bloc.dispatch(Refresh(edit: true));
      /////

      var res = await r.newReddit(
        document: json,
        type: args.type,
        topic: args.topic,
        community: args.community,
      );

      if (res.statusCode != 200) {
        info(context, '发布失败，请重试');
        return;
      }

      setString('_article', '');
      _bloc.dispatch(RedditRefresh(refresh: true));
      _rbloc.dispatch(FetchReddits(refresh: true));
      _tbloc.dispatch(UpdateTopic());

      Navigator.maybePop(context);
    }

    return CtNoRipple(
      icon: Icons.check,
      onTap: post
    );
  }
}

class EditActions extends StatelessWidget {
  final bool update;
  final ScreenshotController controller;
  final VoidCallback toEdit;
  final ArticleArgs args;
  final ZefyrController zefyrController;
  EditActions({
      this.update,
      this.controller,
      this.toEdit,
      this.args,
      this.zefyrController
  });

  @override
  Widget build(BuildContext context) {
    final RefreshBloc _bloc = BlocProvider.of<RefreshBloc>(context);
    final RedditBloc _rbloc = BlocProvider.of<RedditBloc>(context);
    final TopicBloc _tbloc = BlocProvider.of<TopicBloc>(context);
    
    post() async {
      final xReq.Requests r = await xReq.Requests.init();
      final String json = jsonEncode(zefyrController.document);

      FocusScope.of(context).requestFocus(FocusNode());
      if (!zefyrController.document.toPlainText().contains(RegExp(r'\S+'))) {
        info(context, '请填写文章内容');
        return;
      }

      _bloc.dispatch(Refresh(edit: true));
      var res = await r.newReddit(
        document: json,
        type: args.type,
        community: args.community,
      );

      if (res.statusCode != 200) {
        info(context, '发布失败，请重试');
        return;
      }

      _bloc.dispatch(RedditRefresh(refresh: true));
      _rbloc.dispatch(FetchReddits(refresh: true));

      Navigator.maybePop(context);
      Navigator.maybePop(context);
    }

    toTop() async {
      final xReq.Requests r = await xReq.Requests.init();
      _bloc.dispatch(Refresh(edit: true));

      var res = await r.updateRedditTime(id: args.id);
      if (res.statusCode == 200) {
        _bloc.dispatch(RedditRefresh(refresh: true));
        _rbloc.dispatch(FetchReddits(refresh: true));
      } else {
        info(context, '置顶失败，请重试');
        return;
      }

      Navigator.maybePop(context);
      Navigator.maybePop(context);
    }
    
    delete() async {
      final xReq.Requests r = await xReq.Requests.init();
      _bloc.dispatch(Refresh(edit: true));

      var res = await r.deleteReddit(id: args.id);

      if (res.statusCode == 200) {
        _bloc.dispatch(RedditRefresh(refresh: true));
        _rbloc.dispatch(FetchReddits(refresh: true));
        _tbloc.dispatch(UpdateTopic());
      } else {
        info(context, '删除失败，请重试');
        return;
      }

      Navigator.maybePop(context);
      Navigator.maybePop(context);
    }

    alertDelete(BuildContext ctx) {
      Navigator.pop(ctx);
      alert(
        context,
        title: '删除文章?',
        ok: Text('确定'),
        action: delete,
      );
    }

    alertPost(BuildContext ctx) {
      Navigator.pop(ctx);
      alert(
        context,
        title: '发布文章?',
        action: post,
      );
    } 

    // share() async {
    //   Navigator.pop(context);
    //   File image = await controller.capture(pixelRatio: 1.5);
    //   String name = DateTime.now().toString();
    //   await Share.file(name, "$name.png", image.readAsBytesSync(), 'image/png');
    // }
    
    return CtNoRipple(
      icon: Icons.more_horiz,
      onTap: () async {
        showCupertinoModalPopup(
          context: context,
          builder: (ctx) => update == true ? CupertinoActionSheet(
            actions: [
              // CupertinoActionSheetAction(
              //   child: Text('分享'),
              //   onPressed: share,
              // ),
              CupertinoActionSheetAction(
                child: Text('置顶'),
                onPressed: toTop,
              ),
              CupertinoActionSheetAction(
                child: Text('编辑'),
                onPressed: toEdit,
              ),
              CupertinoActionSheetAction(
                child: Text('删除'),
                onPressed: () => alertDelete(ctx),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('取消'),
              onPressed: () => Navigator.pop(context)
            ),
          ) : CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                child: Text('发布'),
                onPressed: () => alertPost(ctx)
              ),
              CupertinoActionSheetAction(
                child: Text('编辑'),
                onPressed: toEdit,
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('取消'),
              onPressed: () => Navigator.pop(context)
            )
          )
        );
      }
    );
  }
}
