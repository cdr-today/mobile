import 'package:flutter/material.dart';
import 'package:cdr_today/navigations/args.dart';

class Article extends StatelessWidget {
  final ArticleArgs args;
  Article({ this.args });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('文章详情')),
      body: Container(
        child: Column(
          children: <Widget>[
            Text(
              args.title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600
              )
            ),
            Divider(),
            Container(
              child: Text(
                args.content,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400)
              ),
              padding: EdgeInsets.only(top: 10.0),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start
        ),
        padding: EdgeInsets.all(20.0),
      )
    );
  }
}
