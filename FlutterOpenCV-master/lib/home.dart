import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv/opencv.dart';
import 'package:opencvApp/helper/filters.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _picker = ImagePicker();
  String _version = '';

  List<FilterData> filters = [
    FilterData(name: "Hot", filter: FilterUtils.applyHot),
    FilterData(name: "Ocean", filter: FilterUtils.applyOcean),
    FilterData(name: "2D", filter: FilterUtils.applyFilter2D),
    FilterData(name: "Linhas", filter: FilterUtils.applyLines),
    FilterData(name: "Twilight", filter: FilterUtils.applyTwilight),
    FilterData(name: "Preto/Branco", filter: FilterUtils.applyThreshold),
  ];
  
  File _file;
  Image _imagem;

  _cancelApplyFilter() {
    if(_file == null) return;
    
    setState(() {
      _imagem = Image.file(_file);
    });
  }

  _getImageByGalery() async {

    var pickerFile = await _picker.getImage(
      source: ImageSource.gallery
    );
    
    if(pickerFile != null){
      var file = File(pickerFile.path);
      
      setState(() {
        _file = file;
       _imagem = Image.file(file);
      });
    }

  }
  
  _initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await OpenCV.platformVersion;
      setState(() => _version = platformVersion);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

  }


  @override
  void initState() {    
    super.initState();
    _initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: Text(" ${_version.toUpperCase()} FILTER"),
      ),
      body: Container(
        color: Colors.grey[850],
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton.icon(
                    icon: Icon(Icons.add_a_photo, color: Colors.white,), 
                    label: Text('Adicionar', style: TextStyle(color: Colors.white),),
                    onPressed: _getImageByGalery
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.cancel, color: Colors.white), 
                    label: Text('Cancelar', style: TextStyle(color: Colors.white),),
                    onPressed: _cancelApplyFilter
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.maxFinite,
                margin: EdgeInsets.only(bottom: 10.0, top: 10.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all()
                ),
                child: _imagem != null ? _imagem : null,
              ),
            ),
            Container(
              height: 80.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: filters.map((f) {
                  return GestureDetector(
                    onTap: () async {
                      if(_file == null) return;

                      var result = await f.filter(_file);
                      setState(() { _imagem = result; });
                    },
                    child: Container(
                      width: 80.0,
                      margin: EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7.0),
                        border: Border.all(color: Colors.white)
                      ),
                      child: Center(
                        child: Text(f.name, 
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        )
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}