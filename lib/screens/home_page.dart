import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:reminder/models/reminder_model.dart';
import 'package:reminder/screens/edit_reminder.dart';
import 'package:reminder/utils/color.dart';
import 'package:reminder/utils/textstyle.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/local_notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<ReminderModel> reminderList = [];
List<ReminderModel> allReminderList = [];

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  DateTime currDate = DateTime.now();
  int selectedSort = 0;

  @override
  void initState() {
    getListOfMaps();
    initNotification();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      log('yo');
      saveListOfMaps(allReminderList);
    }
  }

  Future<void> saveListOfMaps(List<ReminderModel> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList =
        list.map((map) => jsonEncode(map.toJson())).toList();
    await prefs.setStringList('myList', stringList);
    scheduleAllReminders();
  }

  Future<void> getListOfMaps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList = prefs.getStringList('myList') ?? [];
    List<ReminderModel> list = stringList
        .map((str) => ReminderModel.fromJson(jsonDecode(str)))
        .toList();

    DateTime currentTime = DateTime.now();

    list.removeWhere((reminder) {
      DateTime reminderDateTime =
          parseReminderDateTime(reminder.date!, reminder.time!);
      return reminderDateTime.isBefore(currentTime);
    });

    setState(() {
      allReminderList = list;
      reminderList = allReminderList;
    });
  }

  void addItem(ReminderModel newItem) {
    setState(() {
      int index = reminderList.indexWhere((item) =>
          (item.priority == 'Medium' && newItem.priority == 'High') ||
          (item.priority == 'Low' &&
              (newItem.priority == 'High' || newItem.priority == 'Medium')));

      if (index == -1) {
        allReminderList.add(newItem);
      } else {
        allReminderList.insert(index, newItem);
      }
      if (selectedSort == 0) {
        reminderList = allReminderList;
      }
      if (selectedSort == 1 && newItem.priority == 'High') {
        reminderList.add(newItem);
      }
      if (selectedSort == 2 && newItem.priority == 'Medium') {
        reminderList.add(newItem);
      }
      if (selectedSort == 3 && newItem.priority == 'Low') {
        reminderList.add(newItem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBackground,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              30.h.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        currDate.day.toString().padLeft(2, '0'),
                        style: khand(white, 60.sp, FontWeight.bold),
                      ),
                      10.w.horizontalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${DateFormat('MMMM').format(currDate)}, ${currDate.year.toString()}",
                            style: khand(white, 20.sp, FontWeight.normal),
                          ),
                          Text(
                            DateFormat('EEEE').format(currDate),
                            style: khand(white, 20.sp, FontWeight.normal),
                          ),
                        ],
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      ReminderModel? newModel = ReminderModel();
                      newModel = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditReminder(
                                    title: 'Add a new reminder',
                                    reminderModel: newModel!,
                                  )));
                      if (newModel != null) {
                        setState(() {
                          addItem(newModel!);
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 30.h,
                      backgroundColor: highlighColor,
                      child: Icon(
                        Icons.add,
                        size: 30.sp,
                        color: white,
                      ),
                    ),
                  )
                ],
              ),
              20.h.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 1.sw * 0.42,
                    padding: EdgeInsets.all(20.h),
                    decoration: BoxDecoration(
                      color: highlighColor,
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Completed',
                          style: khand(white, 24.sp, FontWeight.normal),
                        ),
                        Text(
                          currDate.day.toString().padLeft(2, '0'),
                          style: khand(white, 60.sp, FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1.sw * 0.42,
                    padding: EdgeInsets.all(20.h),
                    decoration: BoxDecoration(
                      color: highlighColor,
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Scheduled',
                          style: khand(white, 24.sp, FontWeight.normal),
                        ),
                        Text(
                          allReminderList.length.toString(),
                          style: khand(white, 60.sp, FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              10.h.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedSort == 0
                        ? 'All reminders'
                        : selectedSort == 1
                            ? 'High-priority reminders'
                            : selectedSort == 2
                                ? "Medium-priority reminders"
                                : 'Low Priority reminders',
                    style: khand(white, 24.sp, FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          constraints: BoxConstraints(maxHeight: 205.h),
                          context: context,
                          builder: (context) => Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSort = 0;
                                        reminderList = allReminderList;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: 1.sw,
                                      padding: EdgeInsets.all(10.h),
                                      decoration: BoxDecoration(
                                          color: white,
                                          border: Border.symmetric(
                                              vertical: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.5.w))),
                                      child: Text(
                                        "All",
                                        style: khand(Colors.black, 22.sp,
                                            FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSort = 1;
                                        reminderList = allReminderList
                                            .where((element) =>
                                                element.priority == 'High')
                                            .toList();
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: 1.sw,
                                      padding: EdgeInsets.all(10.h),
                                      decoration: BoxDecoration(
                                          color: white,
                                          border: Border.symmetric(
                                              vertical: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.5.w))),
                                      child: Text(
                                        "High",
                                        style: khand(Colors.black, 22.sp,
                                            FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSort = 2;
                                        reminderList = allReminderList
                                            .where((element) =>
                                                element.priority == 'Medium')
                                            .toList();
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: 1.sw,
                                      padding: EdgeInsets.all(10.h),
                                      decoration: BoxDecoration(
                                          color: white,
                                          border: Border.symmetric(
                                              vertical: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.5.w))),
                                      child: Text(
                                        "Medium",
                                        style: khand(Colors.black, 22.sp,
                                            FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSort = 3;
                                        reminderList = allReminderList
                                            .where((element) =>
                                                element.priority == 'Low')
                                            .toList();
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: 1.sw,
                                      padding: EdgeInsets.all(10.h),
                                      decoration: BoxDecoration(
                                          color: white,
                                          border: Border.symmetric(
                                              vertical: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.5.w))),
                                      child: Text(
                                        "Low",
                                        style: khand(Colors.black, 22.sp,
                                            FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort,
                          color: white,
                          size: 26.sp,
                        ),
                        5.w.horizontalSpace,
                        Text(
                          'Sort',
                          style: khand(white, 18.sp, FontWeight.normal),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              ListView.separated(
                itemCount: reminderList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return 10.h.verticalSpace;
                },
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () async {
                      ReminderModel? newModel = reminderList[index];
                      newModel = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditReminder(
                                    title: 'Edit reminder',
                                    reminderModel: newModel!,
                                  )));
                      if (newModel != null && newModel.title != null) {
                        setState(() {
                          reminderList.removeAt(index);
                          addItem(newModel!);
                        });
                      } else if (newModel != null && newModel.title == null) {
                        setState(() {
                          allReminderList.removeWhere(
                              (element) => element == reminderList[index]);
                          if (selectedSort != 0) {
                            reminderList.removeAt(index);
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                          color: tileColors[index % tileColors.length],
                          borderRadius: BorderRadius.circular(10.h)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${index + 1}',
                                style: khand(black, 26.sp, FontWeight.bold),
                              ),
                              10.w.horizontalSpace,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reminderList[index].title!,
                                    style: khand(black, 22.sp, FontWeight.bold),
                                  ),
                                  Text(
                                    reminderList[index].description!,
                                    style:
                                        khand(black, 18.sp, FontWeight.normal),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                reminderList[index].date!,
                                style: khand(black, 18.sp, FontWeight.bold),
                              ),
                              Text(
                                reminderList[index].time!,
                                style: khand(black, 16.sp, FontWeight.normal),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ));
  }
}
