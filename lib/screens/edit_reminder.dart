import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:reminder/models/reminder_model.dart';
import 'package:reminder/utils/color.dart';
import 'package:reminder/utils/textstyle.dart';

class EditReminder extends StatefulWidget {
  final String title;
  final ReminderModel reminderModel;
  const EditReminder(
      {super.key, required this.title, required this.reminderModel});

  @override
  State<EditReminder> createState() => _EditReminderState();
}

class _EditReminderState extends State<EditReminder> {
  TextEditingController title = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController priority = TextEditingController();
  TextEditingController description = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime = TimeOfDay.now();
  @override
  void initState() {
    date.text = widget.reminderModel.date == null
        ? DateFormat('MMMM dd, yyyy').format(selectedDate)
        : widget.reminderModel.date!;
    title.text =
        widget.reminderModel.title == null ? "" : widget.reminderModel.title!;
    description.text = widget.reminderModel.description == null
        ? ""
        : widget.reminderModel.description!;
    time.text =
        widget.reminderModel.time == null ? "" : widget.reminderModel.time!;
    priority.text = widget.reminderModel.priority == null
        ? ""
        : widget.reminderModel.priority!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBackground,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: white,
            size: 26.sp,
          ),
        ),
        title: Text(
          widget.title,
          style: khand(white, 26.sp, FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.h),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                selectedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100, 12, 31),
                      builder: (context, child) => Theme(
                          data: ThemeData(
                              colorScheme: ColorScheme(
                                  background: appBackground,
                                  brightness: Brightness.dark,
                                  primary: white,
                                  onPrimary: Colors.black,
                                  secondary: Colors.white,
                                  onSecondary: white,
                                  error: Colors.red,
                                  onError: white,
                                  onBackground: white,
                                  surface: appBackground,
                                  onSurface: white)),
                          child: child!),
                    ) ??
                    DateTime.now();
                setState(() {
                  date.text = DateFormat('MMMM dd, yyyy').format(selectedDate);
                });
              },
              child: Container(
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                  color: tileColors[1],
                  borderRadius: BorderRadius.circular(10.h),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 26.sp,
                      color: black,
                    ),
                    10.w.horizontalSpace,
                    Text(
                      date.text,
                      style: khand(black, 26.sp, FontWeight.normal),
                    )
                  ],
                ),
              ),
            ),
            10.h.verticalSpace,
            GestureDetector(
              onTap: () async {
                selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                      hour: DateTime.now().hour, minute: DateTime.now().minute),
                  builder: (context, child) => Theme(
                      data: ThemeData(
                          colorScheme: ColorScheme(
                              background: appBackground,
                              brightness: Brightness.dark,
                              primary: white,
                              onPrimary: Colors.black,
                              secondary: Colors.white,
                              onSecondary: white,
                              error: Colors.red,
                              onError: white,
                              onBackground: white,
                              surface: appBackground,
                              onSurface: white)),
                      child: child!),
                );
                if (selectedTime != null) {
                  setState(() {
                    final now = DateTime.now();
                    final dateTime = DateTime(now.year, now.month, now.day,
                        selectedTime!.hour, selectedTime!.minute);
                    time.text = DateFormat('hh:mm a').format(dateTime);
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                  color: tileColors[2],
                  borderRadius: BorderRadius.circular(10.h),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 26.sp,
                      color: black,
                    ),
                    10.w.horizontalSpace,
                    Text(
                      time.text == "" ? 'Select Time' : time.text,
                      style: khand(black, 26.sp, FontWeight.normal),
                    )
                  ],
                ),
              ),
            ),
            10.h.verticalSpace,
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    constraints: BoxConstraints(maxHeight: 160.h),
                    context: context,
                    builder: (context) => Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  priority.text = 'High';
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
                                  style: khand(
                                      Colors.black, 22.sp, FontWeight.normal),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  priority.text = 'Medium';
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
                                  style: khand(
                                      Colors.black, 22.sp, FontWeight.normal),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  priority.text = 'Low';
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
                                  style: khand(
                                      Colors.black, 22.sp, FontWeight.normal),
                                ),
                              ),
                            ),
                          ],
                        ));
              },
              child: Container(
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                  color: tileColors[3],
                  borderRadius: BorderRadius.circular(10.h),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.priority_high_rounded,
                      size: 26.sp,
                      color: black,
                    ),
                    10.w.horizontalSpace,
                    Text(
                      priority.text == "" ? 'Priority' : priority.text,
                      style: khand(black, 26.sp, FontWeight.normal),
                    )
                  ],
                ),
              ),
            ),
            10.h.verticalSpace,
            Container(
              padding: EdgeInsets.all(10.h),
              height: 400.h,
              decoration: BoxDecoration(
                  color: highlighColor,
                  borderRadius: BorderRadius.circular(10.h)),
              child: Column(
                children: [
                  TextField(
                    controller: title,
                    style: khand(white, 24.sp, FontWeight.normal),
                    cursorColor: white,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add a Title',
                        hintStyle:
                            khand(Colors.grey, 24.sp, FontWeight.normal)),
                  ),
                  Divider(
                    color: white,
                    thickness: 0.5,
                  ),
                  TextField(
                    controller: description,
                    style: khand(white, 18.sp, FontWeight.normal),
                    cursorColor: white,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add Description....',
                        hintStyle:
                            khand(Colors.grey, 18.sp, FontWeight.normal)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        child: Row(
          mainAxisAlignment: widget.title == 'Edit reminder'
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                var data = {
                  "title": title.text,
                  "description": description.text,
                  "date": date.text,
                  "time": time.text,
                  "priority": priority.text
                };
                ReminderModel reminder = ReminderModel.fromJson(data);
                Navigator.pop(context, reminder);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 50.h),
                decoration: BoxDecoration(
                    color: tileColors[4],
                    borderRadius: BorderRadius.circular(10.h)),
                child: Text(
                  'Done',
                  style: khand(black, 24.sp, FontWeight.bold),
                ),
              ),
            ),
            Visibility(
              visible: widget.title == 'Edit reminder',
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, ReminderModel());
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 50.h),
                  decoration: BoxDecoration(
                      color: tileColors[1],
                      borderRadius: BorderRadius.circular(10.h)),
                  child: Text(
                    'Delete',
                    style: khand(black, 24.sp, FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
