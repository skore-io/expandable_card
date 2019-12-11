import 'package:flutter/material.dart';

class ToolbarPlayer extends StatefulWidget {
  final PageController toolbarPageViewController;
  final bool hasQuestions;
  final List<Widget> tabList;
  final Color primaryColor;
  final Stream<bool> outFavorite;
  final VoidCallback onLikedPress;
  final Stream<bool> outBookmark;
  final VoidCallback onBookmarkPress;
  final VoidCallback onTapEvent;

  ToolbarPlayer({
    this.toolbarPageViewController, 
    this.hasQuestions = false, 
    this.tabList,
    this.primaryColor,
    this.outFavorite,
    this.onLikedPress,
    this.onBookmarkPress,
    this.outBookmark,
    this.onTapEvent
  });

  @override
  _ToolbarPlayerState createState() => _ToolbarPlayerState();
}

class _ToolbarPlayerState extends State<ToolbarPlayer> with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: widget.hasQuestions ? 2 : 1, vsync: this);
    widget.toolbarPageViewController.addListener(() {
      tabController.animateTo(widget.toolbarPageViewController.page.round());
    });
    super.initState();
  }

  Widget tabMenu() {
    return Container(
      child: TabBar(
        isScrollable: true,
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
        controller: tabController,
        onTap: (index) {
          widget.toolbarPageViewController.animateToPage(index, duration: Duration(seconds: 1), curve: Curves.easeOutCirc);
          widget.onTapEvent();
        },
        // tabs: widget.hasQuestions ? <Widget>[Tab(text: 'Activities'), Tab(text: 'Comments')] : <Widget>[Tab(text: 'Comments')],
        tabs: widget.tabList
      ),
    );
  }

  Color getColor(AsyncSnapshot<bool> snapshot) {
    return snapshot.data ? widget.primaryColor : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: tabMenu()),
        Row(
          children: <Widget>[
            StreamBuilder<bool>(
              stream: widget.outFavorite,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }
                return IconButton(
                    onPressed: widget.onLikedPress,
                    iconSize: 30,
                    icon: Icon(Icons.favorite, color: getColor(snapshot)));
              },
            ),
            StreamBuilder<bool>(
              stream: widget.outBookmark,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return IconButton(
                    onPressed:widget.onBookmarkPress,
                    iconSize: 30,
                    icon: Icon(Icons.bookmark, color: getColor(snapshot)));
              },
            ),
          ],
        ),
      ],
    );
  }
}
