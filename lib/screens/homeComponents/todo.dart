import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

// Replace these imports with actual paths to your components
import '../../components/search_bar.dart'; // Custom search bar component
import '../../components/addtask.dart';   // Dialog to add tasks
import '../../components/delete.dart';   // Dialog to delete tasks
import '../../components/task.dart';     // Task model

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  List<Task> _tasks = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _searchController.clear();
      }
      setState(() {});
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    // Initialize notifications and load saved tasks
    _initializeNotifications();
    _loadTasks();
  }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      List<dynamic> taskList = json.decode(tasksJson);
      setState(() {
        _tasks = taskList.map((task) => Task.fromJson(task)).toList();
      });
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = json.encode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  // Schedule a notification for a task
  
Future<void> _scheduleNotification(Task task) async {
  try {
    // Define the expected date format
    final DateFormat formatter = DateFormat('dd/MM/yyyy h:mm a');
    final DateTime dateTime = formatter.parse(task.dueDate);

    // Schedule notification if the due date is in the future
    if (dateTime.isAfter(DateTime.now())) {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.hashCode, // Unique ID for the notification
        'Hey There!!',
        "Don't forget about ${task.name}",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Notifications',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  } catch (e) {
    print("Failed to schedule notification: $e");
  }
}

  void _showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteTaskDialog(
          task: task,
          onDelete: () {
            setState(() {
              _tasks.remove(task);
              _saveTasks(); // Save updated task list
            });
          },
        );
      },
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog(
          onAddTask: (task) {
            setState(() {
              _tasks.add(task);
              _saveTasks(); // Save updated task list
              _scheduleNotification(task); // Schedule a notification
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = _tasks
        .where((task) => task.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 19, 42),
      body: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: Color.fromARGB(255, 10, 19, 42),
                floating: false,
                pinned: true,
                snap: false,
                elevation: 0,
                expandedHeight: 80.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: CustomSearchBar(
                    searchController: _searchController,
                    focusNode: _focusNode,
                    hintText: 'Search tasks...',
                    onSearchQueryChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ),
              ),
             SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  Task task = filteredTasks[index];

                  // Find the index of the task in the original list
                  int originalIndex = _tasks.indexOf(task);

                  return Dismissible(
                    key: Key(task.name),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        // Remove the task from the original list
                        _tasks.removeAt(originalIndex);
                        _saveTasks(); // Save updated task list
                      });

                      // Show a Snackbar to undo delete action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Task "${task.name}" deleted.'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              setState(() {
                                _tasks.insert(originalIndex, task);
                                _saveTasks(); // Save restored task
                              });
                            },
                          ),
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: GestureDetector(
                      onLongPress: () {
                        _showDeleteDialog(task); // Show delete dialog
                      },
                      child: Card(
                        color: Color.fromARGB(255, 10, 19, 42),
                        margin: EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      task.event,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      task.dueDate,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: filteredTasks.length,
              ),
),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: Icon(
                      Icons.add,
                      color: Colors.white, // Set the icon color to white
                    ),
        backgroundColor: const Color.fromARGB(255, 40, 102, 165),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}