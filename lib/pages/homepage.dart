import 'package:calendar_app/api_manager/location.dart';
import 'package:calendar_app/api_manager/restful.dart';
import 'package:calendar_app/api_manager/calendarutil.dart';
import 'package:calendar_app/api_manager/deviceInfo.dart';
import 'package:calendar_app/pages/qrscan.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:location/location.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;

import 'loginpage.dart';

const color2 = Color(0xFF6200EE);

late tz.Location currLocation;

class HomePage extends StatefulWidget {
  final String title;

  HomePage({required this.title});

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //VARIABLES INITIALIZATION
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  FirebaseMessaging fcm = FirebaseMessaging.instance;
  late LocationData location;
  final calendarrest = CalendarRest();

  //FIRST THING WILL RUN IN THIS PAGE
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    //ANYTHING REQUIRES AWAIT DOES HERE
    void loadasync() async {
      //FCM SUBSCRIPTION
      await fcm.subscribeToTopic('BestNews');

      //LOCATION, TIMEZONE CONVERTER, TIMEZONE
      location = await initLocation();
      print(location);
      String realtz = tzmap.latLngToTimezoneString(
          location.latitude as double, location.longitude as double);
      currLocation = tz.getLocation(realtz);
      _focusedDay = tz.TZDateTime.now(currLocation);
      print('Location: $currLocation, DateTime: $_focusedDay');

      //DEVICE INFORMATION
      device();

    }

    loadasync();

    /*fcm.getToken().then((token) { //Receiving Token value Firebase Push Notification
      print(token);
    }).catchError((e) {
      print(e);
    });*/
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  //BODY AND CALENDAR
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text(
            '${widget.title}',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: color2,
          bottom: PreferredSize(
              child: Container(
                color: Colors.red,
              ),
              preferredSize: Size.fromHeight(8.0)),
          actions: [
            IconButton(
                icon: Icon(Icons.camera_alt),
                iconSize: 28,
                onPressed: () {
                  if (_selectedDay!.day == tz.TZDateTime.now(malaysia).day &&
                      _selectedDay!.month ==
                          tz.TZDateTime.now(malaysia).month &&
                      _selectedDay!.year == tz.TZDateTime.now(malaysia).year) {
                    _selectedDay = tz.TZDateTime.now(malaysia);
                  }
                  print(_selectedDay);

                  NavigationController(
                      context, 'Camera', '', '', '', _selectedDay);
                }),
            Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: IconButton(
                  icon: Icon(Icons.add),
                  iconSize: 28,
                  onPressed: () {
                    if (_selectedDay!.day == tz.TZDateTime.now(malaysia).day &&
                        _selectedDay!.month ==
                            tz.TZDateTime.now(malaysia).month &&
                        _selectedDay!.year ==
                            tz.TZDateTime.now(malaysia).year) {
                      _selectedDay = tz.TZDateTime.now(malaysia);
                    }
                    print(_selectedDay);

                    NavigationController(
                        context, 'Add', '', '', '', _selectedDay);
                  }),
            )
          ]),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text(
                'Calendar',
                style: TextStyle(fontSize: 30, color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Login'),
              onTap: () {
                NavigationController(
                    context, 'Login', '', '', '', _selectedDay);
              },
            ),
            ListTile(
              title: Text('Close'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            /*eventLoader: _getEventsForDay,*/
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: CalendarStyle(
              // Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: color2, width: 0.7))),
                child: calendarTask(context, _selectedDay),
          )),
        ],
      ),
    );
  }

  Widget calendarTask(ctx, date) {
    String id = '';
    final calendarrest = CalendarRest();

    //DIALOG
    final AlertDialog dialog = AlertDialog(
      title: Text('Are you sure you want to delete?'),
      content: Text('This will delete the set alarm.'),
      actions: [
        TextButton(
          child: Text('DELETE'),
          onPressed: () {
            calendarrest.deleteData(id);
            Navigator.pop(ctx);
            setState(() {
              (ctx as Element).reassemble();
            });
          },
        ),
        TextButton(
          child: Text('CANCEL'),
          onPressed: () => Navigator.pop(ctx),
        )
      ],
    );

    //FETCHING DATA
    return Scaffold(
      body: FutureBuilder(
        future: calendarrest.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<calendarData> result = snapshot.data as List<calendarData>;

            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: result.length,
                itemBuilder: (BuildContext context, int i) {
                  DateTime updateDate =
                  DateTime.fromMillisecondsSinceEpoch(result[i].date);
                  String formDate =
                  DateFormat('yMMMd').add_jm().format(updateDate);

                  return GestureDetector(
                    onTap: () {
                      NavigationController(context, 'Edit', result[i].title,
                          result[i].task, result[i].id, updateDate);
                    },
                    child: Card(
                      child: ListTile(
                        leading: Text(
                          formDate,
                          style:
                          TextStyle(fontFamily: 'ProximaNova', fontSize: 16),
                        ),
                        title: Text(
                          '${result[i].title}',
                          style:
                          TextStyle(fontFamily: 'ProximaNova', fontSize: 18),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            id = result[i].id;
                            showDialog<void>(
                                context: context, builder: (context) => dialog);
                          },
                        ),
                      ),
                    ),
                  );
                });
          } else if (snapshot.hasError) {
            print('${snapshot.error}');
            return Text(
              "",
              style: TextStyle(fontSize: 20),
            );
          }

          // By default, show a loading spinner.
          return Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 100.0),
                child: CircularProgressIndicator(),
              ));
        },
      ),
    );
  }
}

//DIALOG FOR DELETING & FUTURE BUILDER FOR FETCHING DATA


//NAVIGATION BACK AND FORTH OF ADD AND EDIT PAGE
void NavigationController(context, type, title, task, id, date) async {
  if (type == 'Camera') {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => QRViewExample(),
        fullscreenDialog: true,
      ),
    );
  } else if (type == 'Login') {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LoginPage(),
      ),
    );
  } else {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CalendarAddTask(
          type: type,
          title: title,
          task: task,
          id: id,
          date: date,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  (context as Element).reassemble();
}

//vvvvv
class CalendarAddTask extends StatefulWidget {
  final String type;
  final String title;
  final String task;
  final String id;
  final DateTime date;

  CalendarAddTask(
      {required this.type,
      required this.title,
      required this.task,
      required this.id,
      required this.date});

  @override
  _CalendarAddTaskState createState() => _CalendarAddTaskState();
}

//FORM FOR EDIT AND ADD TASK PAGE
class _CalendarAddTaskState extends State<CalendarAddTask> {
  String DateText = '';
  String TimeText = '';
  String loadTitle = ''; //fetched title
  String loadTask = ''; //fetched task
  List upChange = []; //to detect which field has changed

  late DateTime _selectedDate,
      loadDate,
      tempDate; //tempDate = fix fetched, loadDate = dynamic fetched
  TimeOfDay _selectedTime = TimeOfDay(hour: 00, minute: 00);

  final Ctrltitle = TextEditingController();
  final Ctrltask = TextEditingController();
  final calendarR = CalendarRest();

  void postTask(ctx) async {
    if (widget.type == 'Add') {
      await calendarR.createData(loadDate, Ctrltitle.text, Ctrltask.text);
      (ctx as Element).reassemble();
      Navigator.pop(ctx);
    } else if (widget.type == 'Edit') {
      await calendarR.updateData(
          widget.id, loadDate, Ctrltitle.text, Ctrltask.text, upChange);
      (ctx as Element).reassemble();
      Navigator.pop(ctx);
    }
  }

  @override
  void dispose() {
    Ctrltitle.dispose();
    Ctrltask.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (DateText == '' && TimeText == '') {
      loadDate = tempDate = widget.date;
    }

    if (DateText == '') {
      _selectedDate = loadDate;
      DateText = DateFormat('yMMMEd').format(loadDate);
    }
    if (TimeText == '') {
      _selectedTime = TimeOfDay.fromDateTime(loadDate);
      TimeText = DateFormat('jm').format(loadDate);
    }

    textChange(selectedDate) {
      _selectedDate = loadDate = new DateTime(selectedDate.year,
          selectedDate.month, selectedDate.day, loadDate.hour, loadDate.minute);
      setState(() {
        DateText = DateFormat('yMMMEd').format(selectedDate);
      });
    }

    textChange2(selectedTime) {
      _selectedTime = selectedTime;
      loadDate = new DateTime(loadDate.year, loadDate.month, loadDate.day,
          selectedTime.hour, selectedTime.minute);
      setState(() {
        TimeText = DateFormat('jm').format(loadDate);
      });
    }

    if (widget.type == 'Edit') {
      Ctrltitle.text = loadTitle = widget.title;
      Ctrltask.text = loadTask = widget.task;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6200EE),
        title: Text(
          '${widget.type} Task',
          style: TextStyle(fontSize: 24),
        ),
        actions: [
          TextButton(
              onPressed: () {
                postTask(context);
              },
              child: Text(
                'Save',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 12,
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.only(left: 28),
              child: TextFormField(
                controller: Ctrltitle,
                style: TextStyle(fontSize: 28),
                cursorColor: Colors.blueGrey,
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                onChanged: (text) {
                  if (widget.type == 'Edit') {
                    if (text != loadTitle) {
                      if (!upChange.contains(1)) {
                        upChange.add(1);
                      }
                    } else {
                      upChange.remove(1);
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Add Title',
                  labelStyle: TextStyle(fontSize: 30, color: Colors.blueGrey),
                  border: InputBorder.none,
                ),
              ),
            ),
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1, color: Colors.grey))),
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.only(top: 15, right: 15, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.assignment),
                    onPressed: null,
                  ),
                  SizedBox(
                    width: 340,
                    child: TextFormField(
                      controller: Ctrltask,
                      style: TextStyle(fontSize: 24),
                      cursorColor: Colors.blueGrey,
                      inputFormatters: [LengthLimitingTextInputFormatter(30)],
                      onChanged: (text) {
                        if (widget.type == 'Edit') {
                          if (text != loadTask) {
                            if (!upChange.contains(2)) {
                              upChange.add(2);
                            }
                          } else {
                            upChange.remove(2);
                          }
                        }
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Details',
                          hintStyle: TextStyle(color: Colors.blueGrey)),
                    ),
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1, color: Colors.grey))),
          ),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: GestureDetector(
                  child: Text(
                    '$DateText',
                    style: TextStyle(fontSize: 22),
                  ),
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: kFirstDay,
                      lastDate: kLastDay,
                    ).then((pickedDate) {
                      if (pickedDate == null) {
                        return;
                      }
                      textChange(pickedDate);
                      if (tempDate.year != pickedDate.year ||
                          tempDate.month != pickedDate.month ||
                          tempDate.day != pickedDate.day) {
                        if (!upChange.contains(3)) {
                          upChange.add(3);
                        }
                      } else {
                        if (loadDate == tempDate) {
                          upChange.remove(3);
                        }
                      }
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: GestureDetector(
                  child: Text(
                    '$TimeText',
                    style: TextStyle(fontSize: 22),
                  ),
                  onTap: () {
                    showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    ).then((pickedTime) {
                      if (pickedTime == null) {
                        return;
                      }
                      textChange2(pickedTime);
                      if (tempDate.hour != pickedTime.hour ||
                          tempDate.minute != pickedTime.minute) {
                        if (!upChange.contains(3)) {
                          upChange.add(3);
                        }
                      } else {
                        if (loadDate == tempDate) {
                          upChange.remove(3);
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
