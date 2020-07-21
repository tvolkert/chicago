// Licensed to the Apache Software Foundation (ASF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The ASF licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class LinkButton extends StatefulWidget {
  const LinkButton({
    Key key,
    this.image,
    this.text,
    this.onPressed,
  }) : super(key: key);

  final ImageProvider image;
  final String text;
  final VoidCallback onPressed;

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        setState(() {
          hover = true;
        });
      },
      onExit: (PointerExitEvent event) {
        setState(() {
          hover = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.image != null)
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: Image(image: widget.image),
              ),
            Text(
              widget.text,
              style: TextStyle(
                color: Color(0xff2b5580),
                decoration: hover ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
