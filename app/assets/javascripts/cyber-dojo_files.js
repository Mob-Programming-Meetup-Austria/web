/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Filenames
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadInitialFile = () => cd.loadFile(topFilename());

  let theCurrentFilename = '';
  let theLastNonOutputFilename = '';
  let theLastOutputFilename = 'stdout';

  cd.currentFilename = () => theCurrentFilename;
  cd.eachFilename = (f) => cd.filenames().forEach(f);
  cd.editorRefocus = () => cd.loadFile(cd.currentFilename());
  cd.isOutputFile = (filename) => ['stdout','stderr','status','repl'].includes(filename);

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Load a named file
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadFile = (filename) => {
    // switch to showing filename's contents
    fileDiv(cd.currentFilename()).hide();
    fileDiv(filename).show();
    cd.focusSyntaxHighlightEditor(filename);
    // switch to showing filename
    selectFileInFileList(filename);
    // remember info for Alt-O hotkey
    theCurrentFilename = filename;
    if (cd.isOutputFile(filename)) {
      theLastOutputFilename = filename;
    } else {
      theLastNonOutputFilename = filename;
    }
  };

  const topFilename = () => cd.sortedFilenames()[0];

  const selectFileInFileList = (filename) => {
    // Can't do $('radio_' + filename) because filename
    // could contain characters that aren't strictly legal
    // characters in a dom node id so I do this instead...
    const node = $(`[id="radio_${filename}"]`);
    const previousFilename = cd.currentFilename();
    const previous = $(`[id="radio_${previousFilename}"]`);
    cd.radioEntrySwitch(previous, node);
    setRenameAndDeleteButtons(filename);
  };

  cd.radioEntrySwitch = (previous, current) => {
    // Used in test-page, and history/diff-dialog
    // See app/assets/stylesheets/wide-list-item.scss
    if (previous !== undefined) {
      previous.removeClass('selected');
    }
    $('.filename').removeClass('selected');
    current.addClass('selected');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadTestOutputFiles = (colour, stdout, stderr, status) => {
    cd.fileChange('stdout', { content: stdout });
    cd.fileChange('stderr', { content: stderr });
    cd.fileChange('status', { content: status });
    const empty = (s) => s.length === 0;
    switch (colour) {
      case 'timed_out':
      case 'faulty':
        cd.loadFile('status');
        break;
      case 'red':
      case 'green':
        if (!empty(stdout) || empty(stderr)) {
          cd.loadFile('stdout');
        } else {
          cd.loadFile('stderr');
        }
        break;
      case 'amber':
        if (stdout.length > stderr.length) {
          cd.loadFile('stdout');
        } else {
          cd.loadFile('stderr');
        }
        break;
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.filenames = () => {
    // Gets the kata/edit page filenames. The review/show
    // page/dialog collects filenames in its own way.
    const filenames = [];
    const prefix = 'file_content_for_';
    $(`textarea[id^=${prefix}]`).each(function(_) {
      const id = $(this).attr('id');
      const filename = id.substr(prefix.length, id.length - prefix.length);
      filenames.push(filename);
    });
    return filenames;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Filename hot-key navigation
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // See app/assets/javascripts/cyber-dojo_codemirror.js
  // See app/views/shared/_hotkeys.html.erb
  // Alt-J ==> loadNextFile()
  // Alt-K ==> loadPreviousFile()
  // Alt-O ==> toggleOutputFile()

  cd.loadNextFile = () => {
    const filenames = nextPreviousFilenames();
    const index = filenames.indexOf(cd.currentFilename());
    if (index === -1) {
      const next = 0;
      cd.loadFile(filenames[next]);
    } else {
      const next = (index + 1) % filenames.length;
      cd.loadFile(filenames[next]);
    }
  };

  cd.loadPreviousFile = () => {
    const filenames = nextPreviousFilenames();
    const index = filenames.indexOf(cd.currentFilename());
    if (index === 0 || index === -1) {
      const previous = filenames.length - 1;
      cd.loadFile(filenames[previous]);
    } else {
      const previous = index - 1;
      cd.loadFile(filenames[previous]);
    }
  };

  const nextPreviousFilenames = () => {
    if (cd.isOutputFile(cd.currentFilename())) {
      return ['stdout','stderr','status'];
    } else {
      return cd.sortedFilenames();
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.toggleOutputFile = () => {
    if (cd.isOutputFile(cd.currentFilename())) {
      cd.loadFile(theLastNonOutputFilename);
    } else {
      cd.loadFile(theLastOutputFilename);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // cd.sortedFilenames()
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Returns how the filenames appear in the filename list.
  // Used in two places
  // 1. kata/edit page to help show filename-list
  // 2. review/show page/dialog to help show filename-list

  cd.sortedFilenames = (filenames) => {
    if (filenames === undefined) {
      filenames = cd.filenames(); // default
    }
    const trueFilenames = filenames.slice().filter(filename => !cd.isOutputFile(filename));
    trueFilenames.sort(orderer);
    return trueFilenames;
  };

  const orderer = (lhs,rhs) => {
    const lhsFileCat = fileCategory(lhs);
    const rhsFileCat = fileCategory(rhs);
    if (lhsFileCat < rhsFileCat) { return -1; }
    else if (lhsFileCat > rhsFileCat) { return +1; }
    else if (lhs < rhs) { return -1; }
    else if (lhs > rhs) { return +1; }
    else { return +1; }
  };

  const fileCategory = (filename) => {
    let category = undefined;
    if (isHighlightFile(filename))    { category = 1; }
    else if (isSourceFile(filename))  { category = 2; }
    else                              { category = 3; }
    // Special cases
    if (filename === 'readme.txt')    { category = 0; }
    // Shell test frameworks (eg shunit2) use .sh as their
    // extension but cyber-dojo.sh is always lowest category
    if (filename === 'cyber-dojo.sh') { category = 3; }
    return category;
  };

  const isHighlightFile = (filename) => {
    return cd.highlightFilenames().includes(filename);
  };

  const isSourceFile = (filename) => {
    return cd.extensionFilenames().find(ext => filename.endsWith(ext));
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // new-file, rename-file, delete-file
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // See app/views/kata/_file_new_rename_delete.html.erb
  // See app/views/kata/_files.html.erb
  // See app/views/kata/_run_tests.js.erb

  cd.fileChange = (filename, file) => {
    cd.fileDelete(filename);
    cd.fileCreate(filename, file);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.fileCreate = (filename, file) => {
    const newFile = makeNewFile(filename, file);
    $('#visible-files-box').append(newFile);
    rebuildFilenameList();
    cd.switchEditorToCodeMirror(filename);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.fileDelete = (filename) => {
    fileDiv(filename).remove();
    rebuildFilenameList();
    cd.loadFile(topFilename());
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.fileRename = (oldFilename, newFilename) => {
    // This should restore the caret/cursor/selection
    // but it currently does not. See
    // https://github.com/cyber-dojo/web/issues/51
    const content = fileContent(oldFilename);
    cd.fileDelete(oldFilename);
    cd.fileCreate(newFilename, { content:content });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const fileContent = (filename) => {
    cd.saveCodeFromIndividualSyntaxHighlightEditor(filename);
    return jqElement(`file_content_for_${filename}`).val();
  };

  const jqElement = (name) => {
    return $(`[id="${name}"]`);
  };

  const fileDiv = (filename) => {
    return jqElement(`${filename}_div`);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const makeNewFile = (filename, file) => {
    const div = $('<div>', {
        class: 'filename_div',
           id: `${filename}_div`
    });
    const text = $('<textarea>', {
      class: 'file_content',
      name: `file_content[${filename}]`,
      id: `file_content_for_${filename}`,
      'spellcheck': 'false',
      'data-filename': filename,
      text: file['content']
    });
    div.append(text);

    return div;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const setRenameAndDeleteButtons = (filename) => {
    const renameFile = $('.rename-file');
    const deleteFile = $('.delete-file');
    const disable = (node) => node.prop('disabled', true );
    const enable  = (node) => node.prop('disabled', false);

    if (cantBeRenamedOrDeleted(filename)) {
      disable(renameFile);
      disable(deleteFile);
    } else {
      enable(renameFile);
      enable(deleteFile);
    }
  };

  const cantBeRenamedOrDeleted = (filename) => {
    return cd.isOutputFile(filename) || filename === 'cyber-dojo.sh';
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const rebuildFilenameList = () => {
    const filenameList = $('#filename-list');
    filenameList.empty();
    cd.sortedFilenames().forEach(filename => {
      filenameList.append(makeFileListEntry(filename));
    });
  };

  const makeFileListEntry = (filename) => {
    const div = $('<div>', {
        class: 'filename',
           id: `radio_${filename}`,
         text: filename
    });
    if (isHighlightFile(filename)) {
      div.addClass('highlight');
    }
    div.click(() => { cd.loadFile(filename); });
    return div;
  };

  return cd;

})(cyberDojo || {}, jQuery);
