import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == '/') {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == '/') {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
    // return ScaleTransition(
    //   scale: animation,
    //   child: child,
    // );
    // return SlideTransition(
    //   position: Tween(
    //     begin: const Offset(0.0, 1.0),
    //     end: const Offset(0.0, 0.0),
    //   ).animate(animation),
    //   child: child,
    // );
    // return Align(
    //   child: SizeTransition(
    //     sizeFactor: animation,
    //     axisAlignment: 0.0,
    //     child: child,
    //   ),
    // );
    // return RotationTransition(
    //   turns: animation,
    //   child: child,
    // );
  }
}
