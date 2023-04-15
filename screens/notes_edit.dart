import 'package:flutter/material.dart';

import 'package:notes_app/models/note.dart';
import '../ColorPalette.dart';
import '../NoteEntry.dart';
import '../NoteTitleEntry.dart';
import '../models/notes_database.dart';
import '../theme/note_colors.dart';

const c1 = 0xFFFDFFFC, c2 = 0xFFFF595E, c3 = 0xFF374B4A, c4 = 0xFF00B1CC, c5 = 0xFFFFD65C, c6 = 0xFFB9CACA,
    c7 = 0x80374B4A;

class NotesEdit extends StatefulWidget {
  final args;

  const NotesEdit(this.args);
  _NotesEdit createState() => _NotesEdit();
}

class _NotesEdit extends State<NotesEdit> {

  void handleColor(currentContext) {
    showDialog(
      context: currentContext,
      builder: (context) => ColorPalette(
        parentContext: currentContext,
      ),
    ).then((colorName) {
      if (colorName != null) {
        setState(() {
          noteColor = colorName;
        });
      }
    });
  }

  String noteTitle = '';
  String noteContent = '';
  String noteColor = 'red';

  TextEditingController _titleTextController = TextEditingController();
  TextEditingController _contentTextController = TextEditingController();

  void handleTitleTextChange() {
    setState(() {
      noteTitle = _titleTextController.text.trim();
    });
  }

  void handleNoteTextChange() {
    setState(() {
      noteContent = _contentTextController.text.trim();
    });
  }


  @override
  void dispose() {
    _titleTextController.dispose();
    _contentTextController.dispose();
    super.dispose();
  }


  Future<void> _insertNote(Note note) async {
    NotesDatabase notesDb = NotesDatabase();
    await notesDb.initDatabase();
    int result = await notesDb.insertNote(note);
    await notesDb.closeDatabase();
  }


  Future<void> _updateNote(Note note) async {
    NotesDatabase notesDb = NotesDatabase();
    await notesDb.initDatabase();
    int result = await notesDb.updateNote(note);
    await notesDb.closeDatabase();
  }



  @override
  void initState() {
    super.initState();
    noteTitle = (widget.args[0] == 'new'? '': widget.args[1]['title']);
    noteContent = (widget.args[0] == 'new'? '': widget.args[1]['content']);
    noteColor = (widget.args[0] == 'new'? 'red': widget.args[1]['noteColor']);

    _titleTextController.text = (widget.args[0] == 'new'? '': widget.args[1]['title']);
    _contentTextController.text = (widget.args[0] == 'new'? '': widget.args[1]['content']);
    _titleTextController.addListener(handleTitleTextChange);
    _contentTextController.addListener(handleNoteTextChange);
  }

  void handleBackButton() async {
    if (noteTitle.length == 0) {
      // Go Back without saving
      if (noteContent.length == 0) {
        Navigator.pop(context);
        return;
      }
      else {
        String title = noteContent.split('\n')[0];
        if (title.length > 31) {
          title = title.substring(0, 31);
        }
        setState(() {
          noteTitle = title;
        });
      }
    }
    // Save New note
    if (widget.args[0] == 'new') {
      Note noteObj = Note(
          title: noteTitle,
          content: noteContent,
          noteColor: noteColor
      );
      try {
        await _insertNote(noteObj);
      } catch (e) {

      } finally {
        Navigator.pop(context);
        return;
      }
    }
    // Update Note
    else if (widget.args[0] == 'update') {
      Note noteObj = Note(
          id: widget.args[1]['id'],
          title: noteTitle,
          content: noteContent,
          noteColor: noteColor
      );
      try {
        await _updateNote(noteObj);
      } catch (e) {

      } finally {
        Navigator.pop(context);
        return;
      }
    }
  }







  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      handleBackButton();
      return
      true;
    },

      child :Scaffold(     // Error here
      backgroundColor: Color(NoteColors[this.noteColor]!['l']!),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.color_lens,
              color: const Color(c1),
            ),
            tooltip: 'Color Palette',
            onPressed: () => handleColor(context),
          ),
        ],
        backgroundColor: Color(NoteColors[this.noteColor]!['b']!),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: const Color(c1),
          ),
          tooltip: 'Back',
          onPressed: () => {handleBackButton()},
        ),

        title: NoteTitleEntry(_titleTextController),
      ),

      body: NoteEntry(_contentTextController),

    ));
  }
}