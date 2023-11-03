import 'package:flutter/material.dart';
import '../model/alarm.dart';
import '../model/constants.dart';
import '../mqtt/MQTTConnectionManager.dart';
import '../mqtt/state/MQTTAppState.dart';

class DetailsPage extends StatefulWidget {
  MQTTAppState currentAppState;
  MQTTConnectionManager manager;

  DetailsPage(MQTTAppState appState, MQTTConnectionManager connectionManager,
      {Key? key})
      : currentAppState = appState,
        manager = connectionManager,
        super(key: key);

  get appState {
    return currentAppState;
  }

  get connectionManager {
    return manager;
  }

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int countTest = 0;

  @override
  Widget build(BuildContext context) {
    {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Test details"),
          ),
          //drawer: NavDrawer(),
          body: _buildDetailsView());
    }
  }

  @override
  void initState() {
    super.initState();
    _clientConnectToTopic();
  }

  Container _clientConnectToTopic() {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          widget.manager.initializeMQTTClient();
          countTest++;
          debugPrint("counter: $countTest");
          widget.manager.connect();
        }));
    return Container();
  }

  Widget _buildDetailsView() {

    return FutureBuilder<List<Alarm>>(
      //future: getAlams(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Alarm>? alarmList = snapshot.data;
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(
                        top: 40.0, bottom: 40.0, left: 10.0, right: 40.0),
                    child: ListView(shrinkWrap: true, children: [
                      Text(
                          "${Constants.DEVICE_ID}: ${snapshot.data![index].toString()}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.justify),
                      Column(children: [
                        Container(
                            alignment: Alignment.bottomCenter,
                            child: const Text(Constants.T,
                                style: TextStyle(), textAlign: TextAlign.left)),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                        ),
                      ])
                    ]));
              });
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        // By default show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
  /*Future<List<Alarm>> getAlams() async {

  }*/
}
