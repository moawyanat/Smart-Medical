// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_constructors, avoid_print

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:sm/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final fb = FirebaseDatabase.instance;
  TextEditingController name = TextEditingController();
  TextEditingController time = TextEditingController();
  var l;
  var g;
  var k;
  var p;
  var qrstr;
  bool morning = false;
  bool afternoon = false;
  bool night = false;
  bool fill = false;
  bool dclose = false;
  bool dopen = false;

  var images = ['1.jpg', '2.jpg'];
  var arr = ['a', 'a', 'a'];
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    getSelectedPref();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final ref = fb.ref().child('Drawer');

    return Scaffold(
      appBar: AppBar(
          title: Center(
            child: Text(
              'Smart Medical Wallet',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          backgroundColor: kPrimary),
      body: Container(
        color: kSecondary,
        child: Column(
          children: [
            // Container(
            //   padding: EdgeInsets.all(50.0),
            //   child: Text(
            //     'current time:${now.hour}:${now.minute}:${now.second}',
            //     style: TextStyle(fontSize: 30, color: Colors.white),
            //   ),
            // ),

            FirebaseAnimatedList(
              query: ref,
              shrinkWrap: true,
              itemBuilder: (context, snapshot, animation, index) {
                var v = snapshot.value.toString();

                g = v.replaceAll(
                    RegExp(
                        "{|} |c: |fill: |title: |afternoon: |morning: |night: "),
                    "");
                g.trim();

                l = g.split(',');
                k = snapshot.key;

                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      k = snapshot.key;
                    });
                    p = int.parse(k);
                    qrstr = "let's Scan it";
                    Future<void> scanQr() async {
                      try {
                        FlutterBarcodeScanner.scanBarcode(
                                '#2A99CF', 'cancel', true, ScanMode.QR)
                            .then((value) {
                          setState(() {
                            dopen = true;
                            dclose = false;
                            qrstr = value;
                          });
                          upd();
                        });
                      } catch (e) {
                        setState(() {
                          qrstr = 'unable to read this';
                        });
                      }
                    }

                    await showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext ctx) {
                          print("$p");
                          print(arr[p - 1]);
                          return StatefulBuilder(builder: ((context, setState) {
                            if (arr[p - 1] != 'a') {
                              return Row(
                                children: [
                                  MaterialButton(
                                    onPressed: () async {
                                      setState(
                                        () => dclose = true,
                                      );
                                      await upd();
                                      Navigator.of(ctx).pop();
                                    },
                                    color: Color(0xFFE55812),
                                    child: Text(
                                      "close",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      setState(
                                        () => dopen = true,
                                      );
                                      await upd();
                                      Navigator.of(ctx).pop();
                                    },
                                    color: Color(0xFFE55812),
                                    child: Text(
                                      "open",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: 20,
                                    left: 20,
                                    right: 20,
                                    // prevent the soft keyboard from covering text fields
                                    bottom:
                                        MediaQuery.of(ctx).viewInsets.bottom +
                                            20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      // ignore: deprecated_member_use
                                      child: FlatButton(
                                        onPressed: scanQr,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 22),
                                        color: kPrimary,
                                        splashColor: kTextSecondary,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(width: 10),
                                            Text(
                                              'Scanner',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: kTextPrimary),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    Text(
                                      qrstr,
                                      style: TextStyle(
                                          color: kPrimary, fontSize: 30),
                                    ),
                                    SizedBox(height: 20),
                                    TextField(
                                      style: TextStyle(
                                        color: kPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      controller: name,
                                      decoration: const InputDecoration(
                                          labelText: 'Name'),
                                    ),
                                    SizedBox(height: 30),
                                    Text(
                                      'When to take?',
                                      style: TextStyle(
                                        color: kPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              morning = !morning;
                                            });
                                          },
                                          child: TimeCard(
                                            icon: FeatherIcons.sunrise,
                                            time: 'Morning',
                                            isSelected: morning,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              afternoon = !afternoon;
                                            });
                                          },
                                          child: TimeCard(
                                            icon: FeatherIcons.sun,
                                            time: 'Afternoon',
                                            isSelected: afternoon,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              night = !night;
                                            });
                                          },
                                          child: TimeCard(
                                            icon: FeatherIcons.moon,
                                            time: 'Night',
                                            isSelected: night,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      children: [
                                        MaterialButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          color: Color(0xFFE55812),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 170,
                                        ),
                                        MaterialButton(
                                          onPressed: () async {
                                            SharedPreferences pref =
                                                await SharedPreferences
                                                    .getInstance();
                                            pref.setString(
                                                arr[p - 1], name.text);
                                            setState(() {
                                              dclose = true;
                                              dopen = false;
                                              fill = true;
                                            });
                                            await upd();
                                            Navigator.of(ctx).pop();
                                          },
                                          color: Color(0xFFE55812),
                                          child: Text(
                                            "ADD",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                          }));
                        });
                  },
                  child: Container(
                    height: 150,
                    padding: EdgeInsets.all(10.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white,
                      elevation: 10,
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: Colors.indigo[100],
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: kTextSecondary,
                          ),
                          onPressed: () async {
                            setState(() {
                              k = snapshot.key;
                            });
                            //ref.child(snapshot.key!).remove();
                            await del(k);
                          },
                        ),
                        title: Text(
                          l[0],
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            l[8] == " true"
                                ? const Text(
                                    " morning",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const Text(" "),
                            l[0] == "true"
                                ? const Text(
                                    " afternoon",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const Text(" "),
                            l[3] == " true"
                                ? const Text(
                                    " night",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const Text(" "),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  getSelectedPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      arr[p - 1] = pref.getString(arr[p - 1]).toString();
      print(arr[p - 1]);
    });
  }

  del(var p) async {
    DatabaseReference ref1 = FirebaseDatabase.instance.ref("Drawer/$p");
    name.text = "Click on the card to fill";
    morning = false;
    afternoon = false;
    night = false;
    fill = false;
    dclose = true;
    dopen = false;
    // time.text = 'Click on the card to fill ';
    await ref1.update({
      "dClose": dclose,
      "dOpen": dopen,
      "fill": fill,
      "title": name.text,
      "barcode": -1,
      "morning": morning,
      "afternoon": afternoon,
      "night": night
    });
    name.clear();

    // time.clear();
  }

  upd() async {
    DatabaseReference ref1 = FirebaseDatabase.instance.ref("Drawer/$k");
    // setState(() {
    //   arr[p - 1] = name.text;
    // });

    await ref1.update({
      "dClose": dclose,
      "dOpen": dopen,
      "fill": fill,
      "title": name.text,
      "morning": morning,
      "afternoon": afternoon,
      "night": night,
      "barcode": qrstr,
    });
    name.clear();
    morning = false;
    afternoon = false;
    night = false;
    fill = false;
  }
}
