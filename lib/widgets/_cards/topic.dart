import 'package:flutter/material.dart';
import 'package:cdr_today/x/time.dart';
import 'package:cdr_today/x/rng.dart';
import 'package:cdr_today/x/_style/color.dart';
import 'package:cdr_today/widgets/avatar.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TopicCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  TopicCard({
      this.title = '',
      this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Text(
                  title,
                  style: TextStyle(
                    color: CtColors.primary,
                    fontSize: 18.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                ),
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.center
              ),
            ]
          ),
          elevation: 0.2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          color: CtColors.gray6
        ),
        margin: EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 10.0
        )
      ),
      onTap: onTap,
    );
  }
}
