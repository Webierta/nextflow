import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path_dart;

import '../models/cloud_file.dart';
import '../models/cuenta_nextcloud.dart';
import '../models/destino.dart';
import '../models/note.dart';
import '../services/nextcloud_api/nextcloud_api.dart';
import '../styles/styles_app.dart';
import '../widgets/bottom_bar_app.dart';
import '../widgets/cuenta_avatar.dart';
import '../widgets/open_dialog.dart';
import '../widgets/snackbar_manager.dart';
import 'open_file_screen.dart';

part 'notes_screen_on_tap_more.dart';

class NotesScreen extends StatefulWidget {
  final CuentaNextcloud cuenta;

  const NotesScreen({super.key, required this.cuenta});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _NotesScreenState extends State<NotesScreen> {
  late NextcloudApi nextcloudApi;
  List<Note> notesApi = [];
  List<Note> notes = [];
  String? category;
  Set<String> categorias = {''};
  Map mapCategories = {};
  String dropdownValue = '';
  bool filterFavorites = false;
  bool isLoading = false;
  bool isGridView = false;
  Map<Note, CloudFile> mapFiles = {};
  int totalNotes = 0;
  TextEditingController renameController = TextEditingController();

  @override
  void initState() {
    nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    dropdownValue = categorias.first;
    initNotes();
    super.initState();
  }

  @override
  void dispose() {
    renameController.dispose();
    super.dispose();
  }

  Future<void> initNotes() async {
    setState(() => isLoading = true);
    final myNotes = await nextcloudApi.getNotes();
    if (myNotes == null) return;
    myNotes.sort(
      (a, b) => a.getName().toLowerCase().compareTo(b.getName().toLowerCase()),
    );

    List<String> countCategorias = [];
    for (var note in myNotes) {
      if (note.category != null) {
        countCategorias.add(note.category!);
        categorias.add(note.category!);
      }
    }
    var map = {};
    for (var cat in countCategorias) {
      if (!map.containsKey(cat)) {
        map[cat] = 1;
      } else {
        map[cat] += 1;
      }
    }

    setState(() {
      notesApi = myNotes;
      notes = myNotes;
      mapCategories = map;
      isLoading = false;
      totalNotes = myNotes.length;
    });
  }

  void onTapNote(Note note) async {
    //print(note.internalPath);
    //String path = path_dart.dirname(note.internalPath);
    //final nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    var fileNote =
        mapFiles[note] ?? await nextcloudApi.getFile(note.internalPath);
    //var fileNote = await nextcloudApi.getFile(note.internalPath);
    if (fileNote == null) return;
    mapFiles[note] = fileNote;
    if (fileNote.typeFile != null &&
        fileNote.typeFile!.startsWith('text/plain') &&
        mounted) {
      previewTxt(fileNote, cat: note.category);
    } else if (fileNote.typeFile != null &&
        fileNote.typeFile!.startsWith('text/markdown') &&
        mounted) {
      previewMd(fileNote, cat: note.category);
    } else {
      if (mounted) {
        SnackbarManager.show(
          context: context,
          msg:
              'Notes only opens text and Markdown files. '
              'Try opening other formats from Files.',
          error: true,
        );
      }
    }
  }

  Future<void> previewTxt(CloudFile note, {String? cat}) async {
    final pathFile = note.filePath(widget.cuenta.userName);
    if (pathFile == null) return;
    //final nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    final txt = await nextcloudApi.readFile(pathFile);
    if (txt == null) return;
    //return txt;
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => OpenFileScreen(
            file: note,
            cuenta: widget.cuenta,
            type: TypeOpenFile.txt,
            content: txt,
            category: cat,
          ),
        ),
      );
    }
  }

  Future<void> previewMd(CloudFile note, {String? cat}) async {
    final pathFile = note.filePath(widget.cuenta.userName);
    if (pathFile == null) return;
    //final nextcloudApi = NextcloudApi(cuenta: widget.cuenta);
    final md = await nextcloudApi.readFile(pathFile);
    if (md == null) return;
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => OpenFileScreen(
            file: note,
            cuenta: widget.cuenta,
            type: TypeOpenFile.md,
            content: md,
            category: cat,
          ),
        ),
      );
    }
  }

  Future<void> changeFavorite(Note note, bool isFavorite) async {
    final update = await nextcloudApi.updateNote(
      id: note.id,
      favorite: isFavorite,
    );
    if (update == true && mounted) {
      initNotes();
      SnackbarManager.show(
        context: context,
        msg: 'Favorite changed successfully!',
      );
    } else if (update == false && mounted) {
      SnackbarManager.show(
        context: context,
        msg: 'Failed to changed favorite',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (category != null) {
      notes = notesApi.where((note) => note.category == category).toList();
      if (filterFavorites == true) {
        notes = notes.where((note) => note.favorite == true).toList();
      }
    } else {
      notes = notesApi;
      if (filterFavorites == true) {
        notes = notes.where((note) => note.favorite == true).toList();
      }
    }
    return Container(
      decoration: StylesApp.backgroundScreen(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: CuentaAvatar(
              cuenta: widget.cuenta,
              size: 30,
              onlyAvatar: true,
            ),
          ),
          title: Text('Notes: ${notes.length}'),
          actions: [
            IconButton(
              tooltip: 'Sort by name',
              onPressed: () {
                setState(() {
                  notes.sort(
                    (a, b) => a.getName().toLowerCase().compareTo(
                      b.getName().toLowerCase(),
                    ),
                  );
                });
              },
              icon: Icon(Icons.sort_by_alpha, size: 32, color: Colors.white),
            ),
            IconButton(
              tooltip: 'Sort by date',
              onPressed: () {
                setState(() {
                  notes.sort((a, b) {
                    //final aDate = FormatDates.toDate(a.lastModified!);
                    //final bDate = FormatDates.toDate(b.lastModified!);
                    //return bDate.compareTo(aDate);
                    return b.modified.compareTo(a.modified);
                  });
                });
              },
              icon: Icon(Icons.date_range, size: 32, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                setState(() => isGridView = !isGridView);
              },
              icon: Icon(
                isGridView ? Icons.list : Icons.grid_view,
                size: 32,
                color: Colors.white,
              ),
            ),
          ],
          bottom: isLoading == false
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: Padding(
                    padding: .symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() => filterFavorites = !filterFavorites);
                          },
                          icon: Icon(
                            Icons.star,
                            size: 32,
                            color: filterFavorites == true
                                ? Colors.yellow
                                : Colors.grey,
                          ),
                        ),
                        //const SizedBox(width: 10),
                        const Spacer(),
                        filterCategory(),
                      ],
                    ),
                  ),
                )
              : null,
        ),
        /*floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Theme.of(context).colorScheme.primary,
          tooltip: 'Add note',
          child: Icon(
            Icons.add,
            size: 42,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),*/
        //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomBarApp(
          cuenta: widget.cuenta,
          destino: Destino.notes,
          funcion: null,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : notes.isEmpty
            ? Center(child: Text('Sin notas'))
            : LayoutBuilder(
                builder: (context, constraints) {
                  if (isGridView) {
                    int columns = (constraints.maxWidth / 200).floor();
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns, // Number of columns
                        crossAxisSpacing: 4, // Space between columns
                        mainAxisSpacing: 4, // Space between rows
                      ),
                      padding: .all(20),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        var note = notes[index];
                        return Card(
                          child: InkWell(
                            onTap: () => onTapNote(note),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [
                                    /*Icon(
                                      Icons.star,
                                      color: note.favorite == true
                                          ? Colors.yellow
                                          : Colors.grey,
                                      size: 42,
                                    ),*/
                                    IconButton(
                                      onPressed: () {
                                        changeFavorite(note, !note.favorite);
                                      },
                                      icon: Icon(
                                        Icons.star,
                                        color: note.favorite == true
                                            ? Colors.yellow
                                            : Colors.grey,
                                        size: 42,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => onTapMore(
                                        context: context,
                                        note: note,
                                      ),
                                      icon: Icon(Icons.more_vert),
                                    ),
                                  ],
                                ),
                                Spacer(flex: 1),
                                Text(note.title),
                                Spacer(flex: 2),
                                if (note.category != null &&
                                    note.category != '')
                                  Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiaryContainer,
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 6),
                                    child: Text(
                                      note.category!,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                /*FittedBox(
                                    child: Chip(
                                      avatar: Icon(Icons.category),
                                      label: Text(note.category!),
                                      side: BorderSide.none,
                                    ),
                                  ),*/
                                //Text(note.category!),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return ListView.separated(
                      shrinkWrap: true,
                      padding: .fromLTRB(20, 20, 20, 60),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return ListTile(
                          onTap: () => onTapNote(note),
                          titleAlignment: ListTileTitleAlignment.top,
                          /*leading: Icon(
                            Icons.star,
                            color: note.favorite == true
                                ? Colors.yellow
                                : Colors.grey,
                            size: 42,
                          ),*/
                          leading: IconButton(
                            onPressed: () {
                              changeFavorite(note, !note.favorite);
                            },
                            icon: Icon(
                              Icons.star,
                              color: note.favorite == true
                                  ? Colors.yellow
                                  : Colors.grey,
                              size: 42,
                            ),
                          ),
                          title: Text(note.title),
                          subtitle: note.category != null
                              ? Text(note.category!)
                              : null,
                          trailing: IconButton(
                            onPressed: () => onTapMore(
                              context: context,
                              note: note,
                              //path: path,
                            ),
                            icon: Icon(Icons.more_vert),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Colors.white54,
                          thickness: 0.2,
                          indent: 20,
                          endIndent: 20,
                        );
                      },
                    );
                  }
                },
              ),
      ),
    );
  }

  Widget filterCategory() {
    return Expanded(
      flex: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          //padding: EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.white30,
              style: BorderStyle.solid,
              width: 0.80,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: dropdownValue,
              //icon: const Icon(Icons.arrow_downward),
              icon: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.filter_alt_outlined, size: 32),
              ),
              elevation: 16,
              //style: const TextStyle(color: Colors.blueAccent),
              //underline: Container(height: 2, color: Colors.blueAccent),
              onChanged: (String? value) {
                setState(() {
                  category = value;
                  if (value == null || value.isEmpty) {
                    category = null;
                  }
                  dropdownValue = value!;
                });
              },
              items: categorias
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: FittedBox(
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            CircleAvatar(
                              child: Text(
                                value.isEmpty
                                    ? '$totalNotes'
                                    : '${mapCategories[value]}',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(value.isEmpty ? 'All' : value),
                          ],
                        ),
                      ),
                      /*child: value.isEmpty
                          ? Text('All')
                          : FittedBox(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    child: Text('${mapCategories[value]}'),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(value),
                                ],
                              ),
                            ),*/
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
