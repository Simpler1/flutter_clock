// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
}

final _lightTheme = {
  _Element.background: Colors.white70,
  _Element.text: Colors.black87,
};

final _darkTheme = {
  _Element.background: Colors.white24,
  _Element.text: Colors.white60,
};

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //   Duration(minutes: 1) - Duration(seconds: _dateTime.second) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light ? _lightTheme : _darkTheme;
    final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final hourTens = hour.substring(0, 1);
    final hourOnes = hour.substring(1);
    final minute = DateFormat('mm').format(_dateTime);
    final minuteTens = minute.substring(0, 1);
    final minuteOnes = minute.substring(1);
    final second = DateFormat('ss').format(_dateTime);
    final secondTens = second.substring(0, 1);
    final secondOnes = second.substring(1);
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Saira',
      fontSize: 35.0,
    );
    double digitWidth = MediaQuery.of(context).size.width / 4 - 11;
    double digitWidthSeconds = 25.0;

    return Column(
      children: <Widget>[
        Container(
          // height: MediaQuery.of(context).size.height * 0.8,
          // width: MediaQuery.of(context).size.width,
          color: Colors.black87,
          child: Center(
            child: DefaultTextStyle(
              style: defaultStyle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  digit(
                    hourTens,
                    width: digitWidth,
                  ),
                  digit(
                    hourOnes,
                    width: digitWidth,
                  ),
                  digit(
                    minuteTens,
                    width: digitWidth,
                  ),
                  digit(
                    minuteOnes,
                    width: digitWidth,
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                DateFormat.yMMMMEEEEd().format(_dateTime.toLocal()),
                style: defaultStyle,
              ),
            ),
            DefaultTextStyle(
              style: defaultStyle,
              child: Row(
                children: [
                  digit(
                    secondTens,
                    width: digitWidthSeconds,
                  ),
                  digit(
                    secondOnes,
                    width: digitWidthSeconds,
                    flip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget border({@required double width}) {
    const double borderFactor = 15.0;
    double height = width * 2;

    return Center(
      child: Row(
        children: <Widget>[
          Container(
            height: height,
            width: width / borderFactor,
            color: Colors.black87,
          ),
          Container(
            height: height,
            width: width / borderFactor * (borderFactor - 2),
          ),
          Container(
            height: height,
            width: width / borderFactor,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget digit(String character, {@required double width, bool flip = false}) {
    final colors = Theme.of(context).brightness == Brightness.light || flip ? _lightTheme : _darkTheme;
    double height = width * 2;

    return Stack(
      children: [
        Container(
          height: height,
          width: width,
          // constraints: BoxConstraints.expand(),
          color: colors[_Element.background],
          child: Column(
            children: <Widget>[
              Container(
                height: height,
                width: width,
                child: Text(
                  character,
                  textScaleFactor: 6,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors[_Element.text]),
                ),
              ),
              Container(
                height: height,
                width: width,
                child: Text(
                  nextDigit(character),
                  textScaleFactor: 6,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors[_Element.text]),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.05, 0.35, 0.65, 0.95],
              colors: [Colors.black87, Colors.black12, Colors.black12, Colors.black87],
            ),
          ),
        ),
        border(width: width),
      ],
    );
  }

  String nextDigit(String digitString) {
    int digit = int.tryParse(digitString);
    return digit < 9 ? (digit + 1).toString() : '0';
  }
}
