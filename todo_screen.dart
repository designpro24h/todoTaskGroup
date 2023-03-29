import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  DateTime selectedDate = DateTime.parse(DateTime.now().toString());

  static var currentDate = DateTime.now();

//
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;

  // final WidgetManager todoManager = WidgetManager();
  final TodoDatabase todoDatabase = TodoDatabase();
  //firebase auth instance
  //
  //firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  var groupsSnapshot = FirebaseFirestore.instance.collection("groups").snapshots();

  String uid = '';
  String? userName;
  bool isDarkMode = false;
  bool isLoading = false;
  //final WidgetManager widgetManager = WidgetManager();
  bool addTask = false;
  List groupList = [];
  final _formKey = GlobalKey<FormState>();

  AuthProvider authProvider = AuthProvider();
  String? myId;
  @override
  void initState() {
    super.initState();
    SizeConfig.orientation = Orientation.portrait;
    SizeConfig.screenHeight = 100;
    SizeConfig.screenWidth = 100;
    //
    getuid();
    getCurrentUserDetails();

    //
  }



  void getCurrentUserDetails() async {
    setState(() {
      isLoading = true;
    });
    await _firestore
        .collection('users')
        // .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc['email'] == _user?.email) {
          if (!mounted) return;
          setState(() {
            userName = doc['fullName'];
            isLoading = false;
          });
        }
      });
    });
  }

  
  getuid() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = await auth.currentUser;
    setState(() {
      uid = user!.uid.toString();
    });
  }

  String? groupIdConver;
  List? listUsergroup = [];
//

  @override
  Widget build(BuildContext context) {
    CollectionReference noteColRef = FirebaseFirestore.instance.collection('todo');

    final Size size = MediaQuery.of(context).size;
    //TodosProvider todosProvider = Provider.of(context);
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: _buildAppBar(context),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // searchBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat.yMMMMd().format(DateTime.now())}',
                        style: homeHeadingTextStyle,
                      ),
                      Text(
                        'Today',
                        style: homeHeadingTextStyle,
                      )
                    ],
                  ),
                  CustomButton(
                    text: "Add Task",
                    //icon: Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateTaskScreen(),
                        ),
                      );
                    },
                  )
                ],
              ),
              _dateBarWidget(),

              const Text(
                "All Tasks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.grey[300]),

              Divider(color: Colors.grey[300]),
              Expanded(
                child: StreamBuilder(
                  stream: TodoDatabase().getTasks(
                    // dateCreate: DateFormat('yyyy-MM-dd').format(currentDate),
                    dateCreate: DateFormat('dd/MM/yyyy').format(currentDate),
                  ),
                  builder: (BuildContext context, AsyncSnapshot<List<TaskModel>> snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading...');
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error getting todo's"),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      const Center(
                        child: CircularProgressIndicator(
                            semanticsLabel: "Loading", color: Colors.teal),
                      );
                    }
                    // List<String> groupsList = [];

                    //  Map<String,dynamic> dataList= snapshot.data!.data() as Map<String,dynamic>;
                    return snapshot.data!.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              var task = snapshot.data![index];

                              print('------in ket qua $task');
                              print('------Kiem tra groupId======');
                              print(task.groupId as List);
                              String groupIdConver;
                              final listUsergroup;
                              listUsergroup = task.groupId as List;
                              for (int i = 0; i < listUsergroup.length; i++) {
                                //print('kiem tra==== $listUsergroup');
                                // listUsergroup[i];
                                groupIdConver = listUsergroup[i];
                                print('kiem tra==== $groupIdConver');
                              }

                              Widget _taskcontainer = TaskContainer(
                                id: task.id,
                                title: task.title,
                                description: task.description,
                                starttime: task.startTime ?? '',
                                endtime: task.endTime ?? '',
                                color: task.color ?? 0,
                                dateCreate: task.dateCreate ?? '',
                                isCompleted: task.isCompleted ?? false,
                                groupId: task.groupId,
                              );
                              return InkWell(
                                  onTap: () {
                                    // Navigator.pushNamed(
                                    //   context,
                                    //   CreateTaskScreen.routeName,
                                    //   arguments: task,
                                    // );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateTaskScreen(task: task),
                                      ),
                                    );
                                  },
                                  child: index % 2 == 0
                                      ? BounceInLeft(
                                          duration: const Duration(milliseconds: 1000),
                                          child: _taskcontainer)
                                      : BounceInRight(
                                          duration: const Duration(milliseconds: 1000),
                                          child: _taskcontainer));
                            },
                          )
                        : Container(
                            child: _nodatawidget(),
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _dateBarWidget() {
    return Container(
      padding: EdgeInsets.only(bottom: 4),
      child: DatePicker(
        DateTime.now(),

        initialSelectedDate: DateTime.now(),
        selectionColor: kPrimaryColor,
        selectedTextColor: kPrimaryLightColor,
        dateTextStyle: GoogleFonts.lato(
          textStyle:
              const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(fontSize: 10.0, color: Colors.grey),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(fontSize: 10.0, color: Colors.grey),
        ),
        // deactivatedColor: Colors.white,

        onDateChange: (DateTime newdate) {
          // New date selected

          setState(
            () {
              currentDate = newdate;
            },
          );
        },
      ),
    );
  
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: Get.isDarkMode ? ThemeData.dark().primaryColor : kPrimaryLightColor,
      child: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          //Drawerheader
          DrawerHeader(
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.transparent : Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ListTile(
                leading: const CircleAvatar(
                  //default profile image
                  //TODO: change to user profile image when available from firestore
                  backgroundImage: AssetImage('assets/images/profile_avatar.png'),
                ),
                title: Text(
                  "Hello $userName",
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: Text("${_user!.email}"),
                trailing: IconButton(
                  onPressed: () {
                    //configure dark mode
                    Get.isDarkMode
                        ? Get.changeThemeMode(ThemeMode.light)
                        : Get.changeThemeMode(ThemeMode.dark);
                    setState(() {
                      isDarkMode = true;
                    });
                  },
                  icon: Get.isDarkMode ? const Icon(Icons.dark_mode) : const Icon(Icons.light_mode),
                ),
                onTap: () {
                  Get.to(ProfileScreen());
                },
              ),
            ),
          ),
          //end header
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              //  Get.to(TodoView());
              // nextScreen(context, LanguagesScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              //  Get.to(TodoView());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Get.to(SettingsView());
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Get.to(AboutView());
            },
          ),
          //exit
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Logout'),
            onTap: () async {
              //TODO: logout and exit
              //check to see if user is signed in

              // context.read<AuthProvider>().userSignOut();
              // Navigator.pop(context);
              if (_auth.currentUser != null) {
                _auth.signOut();
                // Get.to(LoginPage());
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
              }
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      // leading: Icon(
      //   Icons.language,
      //   color: tdBGColor,
      // ),
      elevation: 2,
      centerTitle: true,
      title: Text(
        'My Tasks',
        style: Theme.of(context).textTheme.headline1!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Get.isDarkMode ? Colors.white : const Color.fromRGBO(84, 110, 149, 1)),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.segment_outlined),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  Future<void> searchController(String str) async {
    QuerySnapshot allTodos = await FirebaseFirestore.instance
        .collection("ToDo")
        .where("title", isGreaterThanOrEqualTo: str)
        .get();
    setState(() {
      //futureSearchResults = allUsers;
    });
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onTap: () {
          print('===tim kiem===');
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  Widget _nodatawidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/clipboard.png',
            height: 100.0,
          ),
          const SizedBox(height: 3.9),
          Text(
            'There Is No Tasks',
            style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

}
