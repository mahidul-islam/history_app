import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sirah/colors.dart';
import 'package:sirah/timeline/timeline_entry.dart';

/// This widget will paint the article page.
/// It stores a reference to the [TimelineEntry] that contains the relevant information.
class ArticleWidget extends StatefulWidget {
  final TimelineEntry article;

  const ArticleWidget({required this.article, Key? key}) : super(key: key);

  @override
  _ArticleWidgetState createState() => _ArticleWidgetState();
}

/// The [State] for the [ArticleWidget] will change based on the [article]
/// parameter that's used to build it.
/// It is stateful because we rely on some information like the title, subtitle, and the article
/// contents to change when a new article is displayed. Moreover the [FlareWidget]s that are used
/// on this page (i.e. the top [TimelineEntryWidget] the favorite button) rely on life-cycle parameters.
class _ArticleWidgetState extends State<ArticleWidget> {
  /// The information for the current page.
  String _articleMarkdown = "";
  String _title = "";
  String _subTitle = "";

  /// This page uses the `flutter_markdown` package, and thus needs its styles to be defined
  /// with a custom objects. This is created in [initState()].
  late MarkdownStyleSheet _markdownStyleSheet;

  /// Set up the markdown style and the local field variables for this page.
  @override
  initState() {
    super.initState();

    TextStyle style = TextStyle(
        color: darkText.withOpacity(darkText.opacity * 0.68),
        fontSize: 17.0,
        height: 1.5,
        fontFamily: "Roboto");
    TextStyle h1 = TextStyle(
        color: darkText.withOpacity(darkText.opacity * 0.68),
        fontSize: 32.0,
        height: 1.625,
        fontFamily: "Roboto",
        fontWeight: FontWeight.bold);
    TextStyle h2 = TextStyle(
        color: darkText.withOpacity(darkText.opacity * 0.68),
        fontSize: 24.0,
        height: 2,
        fontFamily: "Roboto",
        fontWeight: FontWeight.bold);
    TextStyle strong = TextStyle(
        color: darkText.withOpacity(darkText.opacity * 0.68),
        fontSize: 17.0,
        height: 1.5,
        fontFamily: "RobotoMedium");
    TextStyle em = TextStyle(
        color: darkText.withOpacity(darkText.opacity * 0.68),
        fontSize: 17.0,
        height: 1.5,
        fontFamily: "Roboto",
        fontStyle: FontStyle.italic);
    _markdownStyleSheet = MarkdownStyleSheet(
      a: style,
      p: style,
      code: style,
      h1: h1,
      h2: h2,
      h3: style,
      h4: style,
      h5: style,
      h6: style,
      em: em,
      strong: strong,
      blockquote: style,
      img: style,
      blockSpacing: 20.0,
      listIndent: 20.0,
      blockquotePadding: const EdgeInsets.all(20.0),
    );
    setState(() {
      _title = widget.article.label;
      _subTitle = widget.article.formatYearsAgo();
      _articleMarkdown = "";
      loadMarkdown('');
      // if (widget.article.articleFilename != null) {}
    });
  }

  /// Load the markdown file from the assets and set the contents of the page to its value.
  void loadMarkdown(String filename) async {
    rootBundle
        .loadString("assets/articles/sample.txt" + filename)
        .then((String data) {
      setState(() {
        _articleMarkdown = data;
      });
    });
  }

  /// This widget is wrapped in a [Scaffold] to have the classic Material Design visual layout structure.
  /// It uses the [BlocProvider] to find out if this element is part of the favorites, to have the icon properly set up.
  /// A [SingleChildScrollView] contains a [Column] that lays out the [TimelineEntryWidget] on top, and the [MarkdownBody]
  /// right below it.
  /// A [GestureDetector] is used to control the [TimelineEntryWidget], if it allows it (...try Amelia Earhart or Newton!)
  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    return Scaffold(
        body: Container(
            color: Color.fromRGBO(255, 255, 255, 1),
            child: Stack(children: <Widget>[
              Column(children: <Widget>[
                Container(height: devicePadding.top),
                SizedBox(
                    height: 56.0,
                    width: double.infinity,
                    child: IconButton(
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_back),
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      color: Colors.black.withOpacity(0.5),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    )),
                Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Row(children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(_title,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: darkText.withOpacity(
                                                  darkText.opacity * 0.87),
                                              fontSize: 25.0,
                                              height: 1.1,
                                              fontFamily: "Roboto",
                                            )),
                                        Text(_subTitle,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: darkText.withOpacity(
                                                    darkText.opacity * 0.5),
                                                fontSize: 17.0,
                                                height: 1.5,
                                                fontFamily: "Roboto"))
                                      ]),
                                ),
                              ]),
                            ),
                            Container(
                                margin:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                                height: 1,
                                color: Colors.black.withOpacity(0.11)),
                            MarkdownBody(
                                data: _articleMarkdown,
                                styleSheet: _markdownStyleSheet),
                            const SizedBox(height: 100),
                          ],
                        )))
              ])
            ])));
  }
}
