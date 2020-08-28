import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar header(context, {bool appTitle=false, String title, bool backButton = true}) {
  return AppBar(
    iconTheme: IconThemeData(color: Colors.white),
    automaticallyImplyLeading: backButton ? true : false,
    title: Text(
      appTitle ? 'J Gram' : title,
      style: appTitle
          ? GoogleFonts.rye(fontSize: 45,color: Colors.white)
          : TextStyle(
              fontSize: 22,
            color: Colors.white),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
