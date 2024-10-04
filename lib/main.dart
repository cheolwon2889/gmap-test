import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //@override
  // Widget build(BuildContext context) {
  //   return ThreeScreen();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'one',
      routes: {
        'three': (context) => ThreeScreen(),
        'two': (context) => TwoScreen(),
        'one': (context) => OneScreen()
      },
    );
  }
}

class OneScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OneScreenState();
  }
}

class OneScreenState extends State<OneScreen> {
  String result = "";
  late List list1;

  void dioGet() async {
    var response = await Dio().get(
        'http://apis.data.go.kr/6260000/BusanPblcPrkngInfoService/getPblcPrkngInfo',
        queryParameters: {
          'serviceKey':
              'M/CIIsu3AmqFB8nORr2A9F+Vwi4PNZsnbZwx5nKHxHS55tC+m28wStA6J+K3CGz07EBTvTvqEiHTcrALgPq4Fg==',
          'pageNo': 1,
          'numOfRows': 10,
          'resultType': 'json'
        });

    if (response.statusCode == 200) {
      setState(() {
        result = response.data.toString();
      });
      list1 = response.data['response']['body']['items']['item'];
    }
  }

  void nextScreen() {
    Navigator.pushNamed(context, 'two', arguments: list1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("공공포털 API 이용하기"),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              ElevatedButton(onPressed: dioGet, child: Text("무료주차장 데이터 가져오기")),
              Text(result),
              ElevatedButton(onPressed: nextScreen, child: Text("화면 목록 보기"))
            ],
          )),
    );
  }
}

class TwoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TwoScreenState();
  }
}
class Parking {
  String pkNam;
  String doroAddr;
  String jibunAddr;
  String xCdnt;
  String yCdnt;

  Parking.fromJson(Map<String, dynamic> json)
      : pkNam = json['pkNam'],
        doroAddr = json['doroAddr'],
        jibunAddr = json['jibunAddr'],
        xCdnt = json['xCdnt'],
        yCdnt = json['yCdnt'];
}

class TwoScreenState extends State<TwoScreen> {
  @override
  Widget build(BuildContext context) {
    List arg = ModalRoute.of(context)?.settings.arguments as List;
    print('two Screen arg : $arg');
    return Scaffold(
      appBar: AppBar(
        title: Text("주차장 목록"),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            Parking parking = Parking.fromJson(arg[index]);
            return ListTile(
              title: Text(parking.pkNam),
              subtitle: Text('${parking.jibunAddr}, ${parking.doroAddr}'),
              trailing: Icon(Icons.more_vert),
              onTap: () {
                if( parking.xCdnt != '-'){
                  Navigator.pushNamed(context,'three', arguments: parking );
                }
              },
            );
          },
          separatorBuilder: (context, index) {
            return Divider(
              height: 2,
              color: Colors.grey,
            );
          },
          itemCount: arg.length),
    );
  }
}

class ThreeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ThreeScreenState();
  }
}



class ThreeScreenState extends State<ThreeScreen> {
  late Parking parking;
  late GoogleMapController mapController;

  // final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Set<Marker> myMarkers = {
  //   Marker(
  //       markerId: MarkerId('abc'),
  //       position: LatLng(45.521563, -122.677433),
  //       infoWindow: InfoWindow(
  //         title: 'yoonmy',
  //         snippet: 'snippet',
  //       ))
  // };



  @override
  Widget build(BuildContext context) {
    parking = ModalRoute.of(context)?.settings.arguments as Parking;
    print('parking??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????? $parking');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(double.parse(parking.xCdnt),double.parse(parking.yCdnt)),
            zoom: 19.0,
          ),
          mapType: MapType.satellite,
          markers: {
            Marker(
                markerId: MarkerId(parking.pkNam),
                position: LatLng(double.parse(parking.xCdnt),double.parse(parking.yCdnt)),
                infoWindow: InfoWindow(
                  title: parking.pkNam,
                  snippet: parking.jibunAddr,
                ))
          },
        ),
      ),
    );
  }
}
