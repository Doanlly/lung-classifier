// ignore_for_file: unused_import

import 'dart:io';
import 'package:ai_app/history_secreen.dart';
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
// import 'package:logger/logger.dart';
import 'classifier.dart';
import 'classifier_quant.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Classification',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Classifier _classifier;



  File? _image;
  final picker = ImagePicker();

  Image? _imageWidget;
  
  img.Image? fox;

  Category? category;
  // ignore: unused_field
  late String _cameraImagePath;
  bool _imageSelected = false;

  @override
  void initState() {
    super.initState();
    _classifier = ClassifierQuant();
  }

  // Future getImage() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.gallery);

  //   setState(() {
  //     _image = File(pickedFile!.path);
  //     _imageWidget = Image.file(_image!,fit: BoxFit.cover,);

  //     _predict();
  //   });
  // }

 Future getImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageWidget = Image.file(_image!, fit: BoxFit.cover);
        _imageSelected = true;
      });

      _predict();
    }
  }

  Future captureImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageWidget = Image.file(_image!, fit: BoxFit.cover);
        _imageSelected = true;
      });

      _predict();
    }
  }

  Future<void> saveToHistory(String imageName, String category, String timestamp) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('imageHistory') ?? [];
   
    history.add('$imageName - $category -$timestamp');

    await prefs.setStringList('imageHistory', history);

  }

  Future<List<String>> getImageHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('imageHistory') ?? [];

    return history;
  }


  void _predict() async {
    if (_imageSelected && _image != null) {
      img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
      var pred = _classifier.predict(imageInput);
      setState(() {
        this.category = pred;
      });
      if (category != null) {
        String timestamp = DateTime.now().toString(); // Lấy thời gian hiện tại
        String imageName = _image!.path;
        String imageCategory = category!.label;
        
        await saveToHistory(imageName, imageCategory, timestamp);
        await GallerySaver.saveImage(_image!.path);
      }
    } else {
      // Hiển thị SnackBar thông báo khi chưa có ảnh nào được chọn
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh trước khi thực hiện phân loại.'),
        ),
      );
    }
  }


//     print('Kết quả phân loại: ${category!.label}');
//   } else {
//     // Lưu ảnh không thành công, xử lý lỗi tại đây
//     print('Lưu ảnh không thành công');
//   }
// }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      var height = constraints.maxHeight;
      var width = constraints.maxWidth;
      return Scaffold(
        
        appBar:  AppBar(
                      centerTitle: true,
                      title:  const Text("APP AI",style: TextStyle(color: Color.fromARGB(255, 226, 233, 245),fontSize: 26),),
                      backgroundColor: const Color.fromARGB(255, 42, 42, 82).withOpacity(0.9),
                      actions: [
                         PopupMenuButton<String>(
                      //onSelected: handleClick,
                      itemBuilder: (BuildContext context) {
                        return {
                          'Nguyễn Văn Đoàn',
                          'Tạ ANh Quân',
        
                           category != null
                                      ? 'Confidence: ${category!.score.toStringAsFixed(3)}'
                                      : '',
                        }.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Column(
                              children: [
                                Text(choice,style: TextStyle(color: Colors.blue[900],fontSize: 14),),
                              
                              //  Text(
                              //     category != null
                              //         ? 'Confidence: ${category!.score.toStringAsFixed(3)}'
                              //         : '',
                              //   overflow: TextOverflow.ellipsis,
                              //   style: const TextStyle(
                              //       color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              // ),
                              
                              ],
                            ),
                          );
                        }).toList();
                        },
                      ),
                      ],
                    ),
        body: Container(
          color: Color.fromARGB(255, 201, 200, 200),
          child: Column(
            children: <Widget>[
              Center(
                child: _image == null
                    ? Container(
                        height: width*0.8,
                        width: width,
                        margin: const EdgeInsets.all(18.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          
                          borderRadius: BorderRadiusDirectional.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xff03001C).withOpacity(0.16),
                                blurRadius: 8,
                                spreadRadius: 8)
                          ],
                          color: const Color.fromARGB(255, 39, 39, 73).withOpacity(0.85),//Color(0xff03001C).withOpacity(0.9),
                        ),
                        child: const Center(child: Text("Hãy chọn ảnh",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),)),
                      )
                    : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImage(image: _imageWidget),
                          ),
                        );
                      },
                      child: Container(
                          height: width*0.85,
                          width: width,
                          margin: const EdgeInsets.only(top: 45.0, left: 5,right: 5,bottom: 20),
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            
                            borderRadius: BorderRadiusDirectional.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xff03001C).withOpacity(0.16),
                                  blurRadius: 8,
                                  spreadRadius: 8)
                            ],
                            color: const Color(0xff03001C).withOpacity(0.8),
                          ),  
                          //child: _imageWidget,
                          child:ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: _imageWidget),
                                        ),
                    ),
              ),
          
              const SizedBox(
                height: 8,
              ),
               Column(
                 children: [
                   Container(
                    padding: const EdgeInsets.all(15.0),
                    margin: const EdgeInsets.all(15.0),
                    height: height * 0.1,
                    width: width,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 17, 48, 73).withOpacity(0.9),
                      borderRadius: BorderRadiusDirectional.circular(12.0),
                      boxShadow: const [
                        BoxShadow(
                                color: Color.fromARGB(255, 107, 103, 103),
                                blurRadius: 6,
                                spreadRadius: 3)
                      ],
                    ),
                    child: Center(
                      child: 
                          Text(
                          category != null ? category!.label : '',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color:Color.fromARGB(255, 197, 190, 190),),
                        ),    
              
                    ),
                   ),

                if (category?.label == 'PNEUMONIA')
                  const Text(
                    'Hệ thống ghi nhận phổi xấu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily:AutofillHints.addressCity ,color: Color.fromARGB(255, 201, 45, 36)),
                  ),
                  ],
                )
                ,
                // Text(
                //   category != null
                //       ? 'Confidence: ${category!.score.toStringAsFixed(3)}'
                //       : '',
                //   style: TextStyle(fontSize: 16),
                //),
              ],
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: FloatingActionButton(
                    heroTag: 'test',
                    backgroundColor: const Color.fromARGB(255, 1, 3, 88).withOpacity(0.7),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) =>  HistoryScreen()),
                      );
                    },
                    tooltip: 'Lịch sử',
                    child: const Icon(Icons.history, color: Color.fromARGB(255, 189, 215, 237)),
                  ),
                ),
              ),
              const SizedBox(width: 160),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  heroTag: 'pick_image_button',
                  backgroundColor: const Color.fromARGB(255, 1, 3, 88).withOpacity(0.7),
                  onPressed: getImage,
                  tooltip: 'Chọn ảnh',
                  child: const Icon(Icons.add_photo_alternate_outlined, color: Color.fromARGB(255, 243, 240, 240)),
                ),
              ),
              const SizedBox(width: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  heroTag: 'capture_image_button',
                  backgroundColor: const Color.fromARGB(255, 1, 3, 88).withOpacity(0.7),
                  onPressed: captureImage,
                  tooltip: 'Chụp ảnh',
                  child: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 243, 240, 240)),
                ),
              ),
            ],
          ),

      )
   ;} );
  }
}
class FullScreenImage extends StatefulWidget {
  final Image? image;
  const FullScreenImage({Key? key, this.image}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
      var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Hero(
          tag: "imageHero",
          child: SizedBox(
            width: width,
            height:height,
            //color: Color.fromARGB(0, 0, 0, 0),
           child: FittedBox(
              fit: BoxFit.contain, // or BoxFit.cover, BoxFit.fill, BoxFit.fitHeight, etc.
              child: widget.image,
            ),
          ),
        ),
      ),
    );
  }
}
 Future<List<String>> getImageHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('imageHistory') ?? [];

    return history;
  }






// Future<void> saveImage() async {
//   final directory = await getApplicationDocumentsDirectory();
//   final imageName = 'tên_${category!.label}.png';
//   final imagePath = '${directory.path}/$imageName';

//   final File newImage = await _image!.copy(imagePath);
//   if (newImage != null) {
//     // Lưu ảnh thành công
//     print('Lưu ảnh thành công: $imagePath');

//     // Lưu ảnh vào thư viện ảnh
//     final result = await ImageGallerySaver.saveFile(imagePath);
//     if (result['isSuccess']) {
//       // Lưu ảnh vào thư viện ảnh thành công
//       print('Lưu ảnh vào thư viện thành công');
//     } else {
//       // Lưu ảnh vào thư viện ảnh không thành công
//       print('Lưu ảnh vào thư viện không thành công: ${result['errorMessage']}');
//     }

//     // In ra màn hình kết quả
//     print('Kết quả phân loại: ${category!.label}');
//   } else {
//     // Lưu ảnh không thành công, xử lý lỗi tại đây
//     print('Lưu ảnh không thành công');
//   }
// }
// Future<void> saveImage() async {
//   if (_image == null) {
//     // No image captured, handle the error
//     print('Chưa chụp ảnh');
//     return;
//   }

//   final directory = await getApplicationDocumentsDirectory();
//   final imageName = '_${category!.label}.png';
//   final imagePath = '${directory.path}/$imageName';

//   final File newImage = await _image!.copy(imagePath);
//   if (newImage != null) {
//     // Lưu ảnh thành công
//     print('Lưu ảnh thành công: $imagePath');

//     // Lưu ảnh vào thư viện ảnh
//     final result = await ImageGallerySaver.saveFile(imagePath);
//     if (result['isSuccess']) {
//       // Lưu ảnh vào thư viện ảnh thành công
//       print('Lưu ảnh vào thư viện thành công');
//     } else {
//       // Lưu ảnh vào thư viện ảnh không thành công
//       print('Lưu ảnh vào thư viện không thành công: ${result['errorMessage']}');
//     }

//     // In ra màn hình kết quả