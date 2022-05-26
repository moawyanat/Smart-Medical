// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_constructors, avoid_print

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:sm/constants.dart';

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
  var qrstr;
  double count = 0;
  bool morning = false;
  bool afternoon = false;
  bool night = false;
  bool fill = false;
  bool dclose = false;
  bool dopen = false;

  @override
  @override
  Widget build(BuildContext context) {
    // final ref = fb.ref().child('Drawer');
    final ref = fb.ref().child('Drawer');
    return Scaffold(
      backgroundColor: kPrimary,
      // appBar: AppBar(
      //     title: Center(
      //       child: Text(
      //         'Smart Medical Wallet',
      //         style: TextStyle(
      //           fontSize: 25,
      //         ),
      //       ),
      //     ),
      //     backgroundColor: kPrimary),
      body: Column(
        children: [
          SizedBox(
            height: 197,
            child: Center(
              child: Text(
                'Smart Medical Wallet',
                style: TextStyle(fontSize: 35, color: kTextPrimary),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 200,
            decoration: BoxDecoration(
                color: kTextPrimary,
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(75.0))),
            child: Column(
              children: [
                SizedBox(height: 80),
                FirebaseAnimatedList(
                  query: ref,
                  shrinkWrap: true,
                  itemBuilder: (context, snapshot, animation, index) {
                    var v = snapshot.value.toString();
                    print(snapshot.value);
                    g = v.replaceAll(
                        RegExp(
                            "{|} |counter: |fill: |title: |afternoon: |morning: |night: "),
                        "");
                    g.trim();

                    l = g.split(',');

                    print(snapshot.value);

                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          k = snapshot.key;
                        });

                        var val = await ref.child("/$k/fill").get();
                        var isfill = val.value.toString();

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
                              return StatefulBuilder(
                                  builder: ((context, setState) {
                                if (isfill == "true") {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: 20,
                                        left: 20,
                                        right: 20,
                                        // prevent the soft keyboard from covering text fields
                                        bottom: MediaQuery.of(ctx)
                                                .viewInsets
                                                .bottom +
                                            20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(width: 40),
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  dclose = false;
                                                  dopen = true;
                                                });
                                                await set();
                                              },
                                              child: StateCard(
                                                icons: FeatherIcons.inbox,
                                                title: 'Open',
                                              ),
                                            ),
                                            SizedBox(width: 40),
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  dclose = true;
                                                  dopen = false;
                                                });

                                                await set();
                                              },
                                              child: StateCard(
                                                icons: Icons
                                                    .closed_caption_disabled_rounded,
                                                title: 'Close',
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 40),
                                        Row(
                                          children: [
                                            SizedBox(width: 40),
                                            GestureDetector(
                                              onTap: () async {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: StateCard(
                                                icons: Icons.cancel,
                                                title: 'Cancel',
                                              ),
                                            ),
                                            SizedBox(width: 40),
                                            GestureDetector(
                                              onTap: () async {
                                                setState(
                                                  () => k = snapshot.key,
                                                );
                                                await del(k);
                                                Navigator.of(ctx).pop();
                                              },
                                              child: StateCard(
                                                icons: Icons.delete,
                                                title: 'Delete',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: 20,
                                        left: 20,
                                        right: 20,
                                        // prevent the soft keyboard from covering text fields
                                        bottom: MediaQuery.of(ctx)
                                                .viewInsets
                                                .bottom +
                                            20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
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
                                          'How many pills do you want to put?',
                                          style: TextStyle(
                                            color: kPrimary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Slider(
                                          value: count,
                                          max: 3,
                                          divisions: 3,
                                          label: count.round().toString(),
                                          onChanged: (double value) {
                                            setState(() {
                                              count = value;
                                            });
                                          },
                                        ),
                                        // SizedBox(height: 30),
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
                        height: 170,
                        padding: EdgeInsets.all(10.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          color: kSecondary,
                          elevation: 20,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: kSecondary,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            tileColor: kPrimary,
                            contentPadding: EdgeInsets.all(12.0),
                            leading: l[5] == " true"
                                ? Icon(
                                    FeatherIcons.checkSquare,
                                    size: 70,
                                    color: kTextSecondary,
                                  )
                                : Icon(
                                    FeatherIcons.plusSquare,
                                    size: 70,
                                    color: kTextSecondary,
                                  ),
                            title: Text(
                              l[6],
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            subtitle: Column(
                              children: [
                                Row(
                                  children: [
                                    l[8] == " true}"
                                        ? Text(
                                            " morning",
                                            style: TextStyle(
                                              color: kTextPrimary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : const Text(" "),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    l[0] == "true"
                                        ? Text(
                                            " afternoon",
                                            style: TextStyle(
                                              color: kTextPrimary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : const Text(" "),
                                    l[2] == " true"
                                        ? Text(
                                            " night",
                                            style: TextStyle(
                                              color: kTextPrimary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : const Text(" "),
                                  ],
                                ),
                                Row(
                                  children: [
                                    l[4] != " 0"
                                        ? Text(
                                            " The number of pills left: " +
                                                l[4],
                                            style: TextStyle(
                                              color: kTextPrimary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : const Text(" "),
                                  ],
                                ),
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
        ],
      ),
    );
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
    morning = false;
    afternoon = false;
    night = false;
    fill = false;
  }

  upd() async {
    DatabaseReference ref1 = FirebaseDatabase.instance.ref("Drawer/$k");

    await ref1.update({
      "counter": count,
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
    // morning = false;
    // afternoon = false;
    // night = false;
    // fill = false;
  }

  set() async {
    DatabaseReference ref1 = FirebaseDatabase.instance.ref("Drawer/$k");

    await ref1.update({
      "dClose": dclose,
      "dOpen": dopen,
      "fill": fill,
    });
  }
}
