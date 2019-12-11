import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sliding_card/components/toolbar_player.dart';

class ExpandableCard extends StatefulWidget {
  ExpandableCard({
    @required this.children,
    this.padding = const EdgeInsets.only(top: 5, left: 20, right: 20),
    this.minHeight = 100,
    this.maxHeight = 500,
    this.hasShadow = true,
    this.backgroundColor = Colors.blueGrey,
    this.hasRoundedCorners = false,
    this.hasHandle = true,
    this.toolbarPageViewController,
    this.hasQuestions = false,
    this.tabList,
    this.primaryColor,
    this.outFavorite,
    this.onLikedPress,
    this.onBookmarkPress,
    this.outBookmark,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double minHeight;
  final double maxHeight;
  final bool hasHandle;
  final bool hasShadow;
  final bool hasRoundedCorners;
  final Color backgroundColor;
  final PageController toolbarPageViewController;
  final bool hasQuestions;
  final List<Widget> tabList;
  final Color primaryColor;
  final Stream<bool> outFavorite;
  final VoidCallback onLikedPress;
  final Stream<bool> outBookmark;
  final VoidCallback onBookmarkPress;

  @override
  State<ExpandableCard> createState() {
    return _ExpandableCardState();
  }
}

class _ExpandableCardState extends State<ExpandableCard> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animationScrollPercent;
  bool _isAnimating = false;
  bool _cardIsExpanded = false;
  double _scrollPercent = 0;
  final _bounceOutCurve = Cubic(.04, .22, .1, 1.21);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  final Widget positionDebugContent = Column(
    children: <Widget>[Text("Hello world"), SizedBox(height: 50), Text("hi")],
  );

  void _startCardDrag(DragStartDetails details) {
    Type runtimeType = details.runtimeType;

    if (mounted) {
      print("_startCardDrag::mounted = true");
    } else {
      print("_startCardDrag::mounted = false");
    }

    setState(() {
      _isAnimating = false;
    });
    _animationController.reset();
  }

  void _expandCard(DragUpdateDetails details) {
    final drag = details.delta.dy;
    if (drag < -0.3 && _scrollPercent < 1) {
      setState(() {
        _scrollPercent -= drag / 500;
      });
    } else if (drag > 0.3 && _scrollPercent > 0) {
      setState(() {
        _scrollPercent -= drag / 500;
      });
    }
  }

  void _endCardDrag(DragEndDetails details) {
    setState(() => _isAnimating = true);
    // BottomCard will animate
    if (!_cardIsExpanded && (details.primaryVelocity < -500 || _scrollPercent > 0.6)) {
      _animationScrollPercent = Tween<double>(begin: _scrollPercent, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: _bounceOutCurve),
      );
      _animationController.forward();
      setState(() {
        _scrollPercent = 1.0;
        _cardIsExpanded = true;
      });
    } else if (_cardIsExpanded && (details.primaryVelocity > 200 || _scrollPercent < 0.6)) {
      _animationScrollPercent = Tween<double>(begin: _scrollPercent, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: _bounceOutCurve),
      );
      _animationController.forward();
      setState(() {
        _scrollPercent = 0.0;
        _cardIsExpanded = false;
      });
    }
    // Card Slider will not expand
    else {
      if (_cardIsExpanded) {
        _animationScrollPercent = Tween<double>(begin: _scrollPercent, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: _bounceOutCurve),
        );
        _animationController.forward();
        setState(() => _scrollPercent = 1.0);
      } else {
        _animationScrollPercent = Tween<double>(begin: _scrollPercent, end: 0.0).animate(
          CurvedAnimation(parent: _animationController, curve: _bounceOutCurve),
        );
        _animationController.forward();
        setState(() => _scrollPercent = 0.0);
      }
    }
  }

  void _onTapEvent() {
    print("nothing :)");

    if (mounted && !_cardIsExpanded) {
      setState(() => _isAnimating = false);

      _animationController.reset();

      setState(() => _isAnimating = true);

      _animationScrollPercent = Tween<double>(begin: _scrollPercent, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: _bounceOutCurve),
      );

      _animationController.forward();

      setState(() {
        _scrollPercent = 1.0;
        _cardIsExpanded = true;
      });
    }
  }

  List<Widget> widgetList(){
    List<Widget> list = widget.children.sublist(0);
    list.insert(0,ToolbarPlayer(
        toolbarPageViewController: widget.toolbarPageViewController,
        hasQuestions: widget.hasQuestions,
        tabList: widget.tabList,
        primaryColor: widget.primaryColor,
        outFavorite: widget.outFavorite,
        onLikedPress: widget.onLikedPress,
        onBookmarkPress: widget.onBookmarkPress,
        outBookmark: widget.outBookmark,
        onTapEvent: _onTapEvent
      ));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        double factor = _isAnimating ? _animationScrollPercent.value : _scrollPercent;
        double top = MediaQuery.of(context).size.height - widget.minHeight - (widget.maxHeight - widget.minHeight) * factor;

      // List<Widget> newWidgetList = List();
      // for (int i = 0; i < widgetList.length; ++i) {
      //   if (widgetList[i] is ToolbarPlayer){
      //     ToolbarPlayer toolbarPlayer = widgetList[i] as ToolbarPlayer;
      //     List<Widget> tabList = toolbarPlayer.tabList;

      //     for (int j = 0; j < tabList.length; ++j){
      //       tabList[j] = GestureDetector(onTap: _onTapEvent, child: tabList[j]);
      //     }
      //     print(tabList);
      //     break;
      //   }
      // }

        return Positioned(
          top: top,
          child: GestureDetector(
            onVerticalDragStart: _startCardDrag,
            onVerticalDragUpdate: _expandCard,
            onVerticalDragEnd: _endCardDrag,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: widget.maxHeight + 50,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: widget.hasRoundedCorners
                    ? BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      )
                    : null,
                boxShadow: [
                  if (widget.hasShadow)
                    BoxShadow(
                      blurRadius: 10.0,
                      spreadRadius: 10,
                      color: Colors.blueGrey[900].withOpacity(0.2),
                    )
                ],
              ),
              child: Padding(
                padding: widget.padding,
                child: Column(
                  children: <Widget>[
                    if (widget.hasHandle) Handle(),
                    SizedBox(height: 10),
                    ...widgetList()
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    print("ExpandableCard::dispose");
    _animationController.dispose();
    super.dispose();
  }
}



class Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.remove,
      color: Colors.white30,
      size: 45,
    );
  }
}
