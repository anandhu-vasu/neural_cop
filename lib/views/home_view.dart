import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neural_cop/controllers/api_controller.dart';
import 'package:neural_cop/utils/globals.dart';
import 'package:neural_cop/utils/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final StreamController<List<Map<String, dynamic>>> _threatController;
  late final Timer _timer;
  late final ApiController _api;
  int? uid;
  String? role;
  String? hostname;

  @override
  void initState() {
    _threatController = StreamController();

    ApiController.init().then((api) async {
      _api = api;
      _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
        _threatController.add(await api.fetchThreats());
      });
      setState(() {
        uid = api.prefs.getInt('uid');
        role = api.prefs.getString('role');
        hostname = api.prefs.getString('hostname');
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(role == 'user'
            ? 'Security'
            : role == 'police'
                ? 'Police'
                : ''),
        actions: [
          if (role == 'user')
            IconButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                      context: context,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30))),
                      builder: (context) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 40),
                          child: FutureBuilder<Map<String, dynamic>?>(
                              future: _api.userProfile(
                                  uid!), // a previously-obtained Future<String> or null
                              builder: (BuildContext context,
                                  AsyncSnapshot<Map<String, dynamic>?>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  Map<String, dynamic> user = snapshot.data!;
                                  return Column(
                                    children: [
                                      const Icon(
                                        Icons.person_pin,
                                        size: 100,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text("${user['fname']} ${user['lname']}",
                                          style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.mail_rounded),
                                        title: Text(user['email']),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.phone),
                                        title: Text(user['phone']),
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                            Icons.location_city_rounded),
                                        title: Text(user['place']),
                                      )
                                    ],
                                  );
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              })));
                },
                icon: const Icon(Icons.person_rounded)),
          IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('login');
                prefs.remove('uid');
                prefs.remove('role');
                prefs.remove('threat_count');
                navigatorKey.currentState?.popAndPushNamed('/login');
              },
              icon: const Icon(Icons.logout_rounded))
        ],
      ),
      body: StreamBuilder(
        stream: _threatController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Exception: ${snapshot.error}");
          }

          if (snapshot.hasData) {
            List<Map<String, dynamic>> threats = snapshot.data!;

            return _listView(threats);
          }

          if (snapshot.connectionState != ConnectionState.waiting) {
            return new Center(
              child: new CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData &&
              snapshot.connectionState != ConnectionState.done) {
            return new Center(
              child: new CircularProgressIndicator(),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _listView(threats) => ListView.builder(
        itemBuilder: (BuildContext ctx, int index) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              clipBehavior: Clip.hardEdge,
              elevation: 20,
              child: Column(
                children: <Widget>[
                  if (hostname != null)
                    SizedBox(
                      height: 275,
                      child: Image.network(
                        "$hostname/${threats[index]['file_location']}",
                        loadingBuilder: (context, child, loadingProgress) =>
                            (loadingProgress == null)
                                ? child
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),
                      ),
                    ),
                  Row(
                    children: [
                      if (uid != null) ...[
                        Expanded(
                          child: TextButton.icon(
                              onPressed: () async {
                                await openMap(threats[index]['latitude'],
                                    threats[index]['longitude']);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black12,
                              ),
                              icon: const Icon(
                                Icons.location_pin,
                                color: Colors.white38,
                                size: 30,
                              ),
                              label: const Text(
                                "Map",
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 16),
                              )),
                        ),
                        Expanded(
                          child: TextButton.icon(
                              onPressed: () async {
                                await _api.removeThreat(threats[index]['id']);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black12,
                              ),
                              icon: const Icon(
                                Icons.report,
                                color: Colors.white38,
                                size: 30,
                              ),
                              label: const Text(
                                "Remove",
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 16),
                              )),
                        ),
                        if (role == 'user')
                          Expanded(
                            child: TextButton.icon(
                                onPressed: () async {
                                  await _api
                                      .forwardThreat(threats[index]['id']);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black12,
                                ),
                                icon: const Icon(
                                  Icons.forward_rounded,
                                  color: Colors.white38,
                                  size: 30,
                                ),
                                label: const Text(
                                  "Forward",
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 16),
                                )),
                          )
                      ]
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: threats.length,
      );

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
