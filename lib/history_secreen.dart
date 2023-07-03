import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:shared_preferences/shared_preferences.dart";

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> imageHistory = [];
  List<List<String>> imageNotes = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }
  Future<void> loadHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> history = prefs.getStringList('imageHistory') ?? [];
  
  List<List<String>> notes = [];
  for (int i = 0; i < history.length; i++) {
    List<String> noteList = prefs.getStringList('imageNotes_$i') ?? [];
    notes.add(noteList);
  }
  

  
  
  setState(() {
    imageHistory = history;
    imageNotes = notes;

  });
}

Future<void> removeNotesFromHistory(int index) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('imageNotes_$index');
}


  void deleteHistory(int index) async {
    setState(() {
      imageHistory.removeAt(index);
      imageNotes.removeAt(index);
    });

    await saveHistory(); // Save the updated list
    await removeNotesFromHistory(index);
     for (int i = index; i < imageNotes.length; i++) {
    await saveNotesToHistory(i, imageNotes[i]);
  }
  }

  Future<void> saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('imageHistory', imageHistory);
  }
Future<void> saveNotesToHistory(int index, List<String> notes) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('imageNotes_$index', notes);
  // Lưu thời gian vào SharedPreferences

}

  @override
  Widget build(BuildContext context) {
  
return Scaffold(
  appBar: AppBar(
   
      centerTitle: true,
      title:  const Text("Lịch sử",style: TextStyle(color: Color.fromARGB(255, 226, 233, 245),fontSize: 18),),
      backgroundColor: Color.fromARGB(255, 57, 57, 113).withOpacity(0.9),
      leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 251, 251, 250)),
            onPressed: () => Navigator.of(context).pop(),
          ), 
  ),
  body: ListView.builder(
    itemCount: imageHistory.length,
    itemBuilder: (BuildContext context, int index) {
      String item = imageHistory[index];
      
      List<String> notes = imageNotes[index];
      String lastItem = item.split('/').last ?? "";
      List<String> splitItems = lastItem.split('-');

      String firstSentence = splitItems.isNotEmpty ? splitItems.first.trim() : "";
    String secondSentence = splitItems.length > 1 ? splitItems[1].trim() : "";
     // Lấy thời gian tương ứng

      return Dismissible(
  key: Key(item), // Key duy nhất cho mỗi phần tử
  direction: DismissDirection.startToEnd, // Hướng vuốt từ trái sang phải
  onDismissed: (direction) => deleteHistory(index), // Hành động khi vuốt
  background: Container(
    color: Colors.red, // Màu nền khi vuốt
    padding: EdgeInsets.symmetric(horizontal: 16),
    alignment: Alignment.centerLeft,
    child: Icon(
      Icons.delete,
      color: Colors.white,
    ),
  ),
  child: Card(
  margin: const EdgeInsets.symmetric(vertical: 8.0),
  child: ListTile(
    contentPadding: const EdgeInsets.all(16.0),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: "$index. Tên ảnh: ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 5, 50, 86),
            ),
            children: [
              TextSpan(
                text: "$firstSentence \n" ?? "",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: "Hệ thống phát hiện: ",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 5, 50, 86),
                    ),
                    children: [
                      TextSpan(
                        text: "$secondSentence",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4.0),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                String copiedText =
                    " Tên ảnh: $firstSentence\nHệ thống phát hiện: $secondSentence\nGhi chú: ${notes.toString()}";
                Clipboard.setData(ClipboardData(text: copiedText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã sao chép nội dung')),
                );
              },
              child: Icon(
                Icons.copy,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (String note in notes)
                  Text(
                    note.isNotEmpty ? "Ghi chú: $note" : "",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
      ],
    ),
    trailing: IconButton(
      color: Color.fromARGB(255, 7, 107, 189),
      icon: Icon(Icons.edit),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController noteController =
                TextEditingController(text: notes.join('\n'));

            return AlertDialog(
              contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 100),
              
              backgroundColor:Color.fromARGB(255, 246, 247, 238) ,
              title: Text('Ghi chú',style: TextStyle(color: Color.fromARGB(255, 2, 29, 137)),),
              content: TextField(
                maxLines: 10,
                minLines: 1,
                controller: noteController,
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 1, 54, 67),
                    
                    
                    )),
                  child: Text('Hủy',style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                       style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 1, 54, 67),
                    
                    
                    )),
                  child: Text('Lưu',style: TextStyle(color: Colors.white),),
                  onPressed: () async {
                    setState(() {
                      notes.clear();
                      notes.addAll(noteController.text.split('\n'));
                    });
                    await saveNotesToHistory(index, notes);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    ),
  ),
),

  );},
  ),
);

  }
}





// class HistoryScreen extends StatefulWidget {
//   @override
//   _HistoryScreenState createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   List<String> imageHistory = [];
//   List<List<String>> imageNotes = [];

//   @override
//   void initState() {
//     super.initState();
//     loadHistory();
//   }

//   Future<void> loadHistory() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> history = prefs.getStringList('imageHistory') ?? [];

//     List<List<String>> notes = [];
//     for (int i = 0; i < history.length; i++) {
//       List<String> noteList = prefs.getStringList('imageNotes_$i') ?? [];
//       notes.add(noteList);
//     }

//     setState(() {
//       imageHistory = history;
//       imageNotes = notes;
//     });
//   }

//   void deleteHistory(int index) async {
//     setState(() {
//       imageHistory.removeAt(index);
//       imageNotes.removeAt(index);
//     });

//     await saveHistory(); // Save the updated list
//   }

//   Future<void> saveHistory() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('imageHistory', imageHistory);
//   }

//   Future<void> saveNotesToHistory(int index, List<String> notes) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('imageNotes_$index', notes);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Lịch sử'),
//       ),
//       body: ListView.builder(
//         itemCount: imageHistory.length,
//         itemBuilder: (BuildContext context, int index) {
//           String item = imageHistory[index];
//           List<String> notes = imageNotes[index];

//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(16.0),
//               title: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(item),
//                   const SizedBox(height: 8.0),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       for (String note in notes)
//                         Text(
//                           note.isNotEmpty ? "Ghi chú: $note" : "",
//                           style: TextStyle(fontSize: 14, color: Colors.grey),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.edit),
//                     onPressed: () {
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           TextEditingController noteController = TextEditingController();

//                           return AlertDialog(
//                             title: Text('Ghi chú'),
//                             content: TextField(
//                               controller: noteController,
//                             ),
//                             actions: [
//                               TextButton(
//                                 child: Text('Hủy'),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                               TextButton(
//                                 child: Text('Lưu'),
//                                 onPressed: () async {
//                                   setState(() {
//                                     notes.add(noteController.text);
//                                   });
//                                   await saveNotesToHistory(index, notes);
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.delete),
//                     onPressed: () => deleteHistory(index),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
