import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cdr_today/blocs/edit.dart';
import 'package:cdr_today/blocs/image.dart';
import 'package:cdr_today/blocs/article_list.dart';
import 'package:cdr_today/navigations/args.dart';

class Edit extends StatefulWidget {
  final ArticleArgs args;
  Edit({ this.args });
  
  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  TextEditingController _titleController;
  TextEditingController _contentController;

  File _image;
  String _title = '';
  String _content = '';

  Future getImage(BuildContext context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final _bloc = BlocProvider.of<ImageBloc>(context);
    
    setState(() {
        if (image != null) {
          _image = image;
          _bloc.dispatch(UploadImageEvent(image: image));
        }
    });
  }

  Future<void> _changeImage(BuildContext context) async {
    final EditBloc _bloc = BlocProvider.of<EditBloc>(context);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('确定'),
              onPressed: () {
                setState(() {
                    _image = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
          title: Text('删除图片?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
        );
      },
    );
  }
  
  @override
  void initState() {
    super.initState();
    if (widget.args.edit == true) {
      _title = widget.args.title;
      _content = widget.args.content;
      _titleController = new TextEditingController(text: widget.args.title);
      _contentController = new TextEditingController(text: widget.args.content);
    } else {
      _titleController = new TextEditingController(text: '');
      _contentController = new TextEditingController(text: '');
    }
  }

  Widget titleWidget() {
    return TextField(
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700
      ),
      decoration: InputDecoration(
        hintText: '标题',
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      scrollPadding: EdgeInsets.all(20.0),
      controller: _titleController,
      onChanged: (String text) {
        setState(() { _title = text; });
      }
    );
  }

  Widget contentWidget(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: titleWidget(),
              padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0, bottom: 5.0),
            ),
            imageWidget(context),
            Container(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '内容',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _contentController,
                onChanged: (String text) => setState(() { _content = text; }),
              ),
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageWidget(BuildContext context) {
    return Center(
      child: _image == null
      ? SizedBox.shrink()
      : GestureDetector(
        child: Image.file(_image),
        onLongPress: () => _changeImage(context)
      ),
    );
  }

  Widget imagePicker(BuildContext context) {
    if (_image == null) {
      return FloatingActionButton(
        onPressed: () => getImage(context),
        child: Icon(Icons.add_a_photo),
      );
    }
    return SizedBox.shrink();
  }

  Widget build(BuildContext context) {
    final EditBloc _bloc = BlocProvider.of<EditBloc>(context);
    final ArticleListBloc _alBloc = BlocProvider.of<ArticleListBloc>(context);
    
    return Scaffold(
      appBar: AppBar(
        actions: _actions(
          context,
          title: _title,
          content: _content,
          id: widget.args.id,
          edit: widget.args.edit,
        ),
        title: Text('编辑'),
      ),
      body: BlocListener<EditBloc, EditState>(
        listener: (context, state) {
          if (state is PublishSucceed) {
            _alBloc.dispatch(ReFetching());
            Navigator.pushNamedAndRemoveUntil(context, '/init', (_) => false);
          } else if (state is UpdateSucceed) {
            _alBloc.dispatch(ReFetching());
            Navigator.pop(context);
          } else if (state is DeleteSucceed) {
            _alBloc.dispatch(ReFetching());
            Navigator.pop(context);
          } else if (state is DeleteFailed) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('删除失败，请重试'),
              ),
            );
          } else if (state is UpdateFailed) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('更新失败，请重试'),
              ),
            );
          }
        },
        child: GestureDetector(
          child: Column(
            children: [
              contentWidget(context),
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ),
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        ),
      ),
      floatingActionButton: imagePicker(context),
      resizeToAvoidBottomPadding: true,
    );
  }
}

//  ------- actions ----------
List<Widget> _actions(
  BuildContext context, {String title, String content, String id, bool edit}
) {
  final EditBloc _bloc = BlocProvider.of<EditBloc>(context);
  
  Widget delete = IconButton(
    icon: Icon(Icons.highlight_off),
    onPressed: () => _neverSatisfied(context, id)
  );

  Widget empty = SizedBox.shrink();

  if (edit != true) {
    delete = empty;
  }

  Builder upload = Builder(
    builder: (context) => IconButton(
      icon: Icon(Icons.check),
      onPressed: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        if (title == null || title == '') {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('请填写文章标题'),
            ),
          );
        } else if (content == null || content == '') {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('请填写文章内容'),
            ),
          );
        } else {
          if (edit != true) {
            _bloc.dispatch(CompletedEdit(title: title, content: content));
          } else {
            _bloc.dispatch(UpdateEdit(id: id, title: title, content: content));
          }
        }
      }
    )
  );
  
  return [delete, upload];
}

Future<void> _neverSatisfied(BuildContext context, String id) async {
  final EditBloc _bloc = BlocProvider.of<EditBloc>(context);
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        actions: <Widget>[
          FlatButton(
            child: Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('确定'),
            onPressed: () {
              _bloc.dispatch(DeleteEdit(id: id));
              Navigator.pop(context);
            },
          ),
        ],
        title: Text('删除文章?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
        ),
      );
    },
  );
}
