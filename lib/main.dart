import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_background/animated_background.dart';

void main() => runApp(MyApp());

class Note {
  String title;
  String content;

  Note({required this.title, required this.content});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  List<Note> notes = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  int? selectedIndex;
  Color backgroundColor = const Color.fromARGB(255,255,255,255);
  ConfettiController confettiController = ConfettiController();
  bool isLoading = false; // Menambahkan variabel isLoading

  void addNote() {
    String title = titleController.text;
    String content = contentController.text;

    if (title.isNotEmpty && content.isNotEmpty) {
      setState(() {
        isLoading = true; // Menampilkan indikator loading
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: SpinKitDoubleBounce(
              color: Colors.blue,  // Warna indikator loading
              size: 50.0,          // Ukuran indikator loading
            ),
          );
        },
      );

      // Simulasikan proses penambahan catatan dengan penundaan
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          if (selectedIndex == null) {
            notes.add(Note(title: title, content: content));
          } else {
            notes[selectedIndex!] = Note(title: title, content: content);
            selectedIndex = null;
          }
          titleController.clear();
          contentController.clear();
          changeBackgroundColor();
          confettiController.play();
          isLoading = false; // Menyembunyikan indikator loading setelah selesai
        });

        Navigator.of(context).pop(); // Tutup dialog indikator loading
      });
    }
  }

  void editNote(int index) {
    titleController.text = notes[index].title;
    contentController.text = notes[index].content;
    setState(() {
      selectedIndex = index;
    });
  }

  void removeNote(int index) {
    setState(() {
      notes.removeAt(index);
      changeBackgroundColor();
    });
  }

  void clearNotes() {
    setState(() {
      notes.clear();
      changeBackgroundColor();
    });
  }

  void changeBackgroundColor() {
    final random = Random();
    final color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    setState(() {
      backgroundColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To Do List Catatan"),
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(),
        vsync: this,
        child: Container(
          color: backgroundColor,
          child: Column(
            children: <Widget>[
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText('Catatan Anda', textStyle: TextStyle(fontSize: 24)),
                  TyperAnimatedText('Tambah, Edit, Hapus', textStyle: TextStyle(fontSize: 18)),
                  FadeAnimatedText('Selamat datang di Aplikasi Catatan', textStyle: TextStyle(fontSize: 18)),
                  ColorizeAnimatedText('Selamat Berkreasi!', textStyle: TextStyle(fontSize: 18), colors: [Colors.red, Colors.blue, Colors.green]),
                ],
                repeatForever: true,
                isRepeatingAnimation: true,
                totalRepeatCount: 100,
                onTap: () {},
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul Catatan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Isi Catatan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : addNote, // Nonaktifkan tombol selama proses loading
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.blue[300],
                ),
                child: Text(selectedIndex != null ? "Edit Catatan" : "Tambah Catatan"),
              ),
              SizedBox(height: 10),
              if (notes.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(notes[index].title),
                        background: Container(
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 16),
                          transform: Matrix4.translationValues(10.0, 0.0, 0.0),
                        ),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            removeNote(index);
                          }
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              notes[index].title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(notes[index].content),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    editNote(index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    removeNote(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: ConfettiWidget(
        confettiController: confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple,Colors.indigo],
      ),
    );
  }
}
