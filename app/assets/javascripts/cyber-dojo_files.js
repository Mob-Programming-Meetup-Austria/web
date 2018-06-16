/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let theCurrentFilename = '';
  let theLastNonOutputFilename = '';

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.currentFilename = () => {
    return theCurrentFilename;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadFile = (filename) => {
    fileDiv(cd.currentFilename()).hide();
    selectFileInFileList(filename);
    fileDiv(filename).show();

    cd.focusSyntaxHighlightEditor(filename);
    theCurrentFilename = filename;
    if (filename !== 'output') {
      theLastNonOutputFilename = filename;
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadNextFile = () => {
    const hiFilenames = cd.hiFilenames(cd.filenames());
    const index = $.inArray(cd.currentFilename(), hiFilenames);
    if (index == -1) {
      const next = 0;
      cd.loadFile(hiFilenames[next]);
    } else {
      const next = (index + 1) % hiFilenames.length;
      cd.loadFile(hiFilenames[next]);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadPreviousFile = () => {
    const hiFilenames = cd.hiFilenames(cd.filenames());
    const index = $.inArray(cd.currentFilename(), hiFilenames)
    if (index === 0 || index === -1) {
      const previous = hiFilenames.length - 1;
      cd.loadFile(hiFilenames[previous]);
    } else {
      const previous = index - 1;
      cd.loadFile(hiFilenames[previous]);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadTestFile = () => {
    cd.loadFile(testFilename());
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.toggleOutputFile = () => {
    if (cd.currentFilename() !== 'output') {
      cd.loadFile('output');
    } else {
      cd.loadFile(theLastNonOutputFilename);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.newFile = (filename, content) => {
    const newFile = makeNewFile(filename, content);
    $('#visible-files-container').append(newFile);
    cd.rebuildFilenameList();
    cd.switchEditorToCodeMirror(filename);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.deleteFile = (filename) => {
    fileDiv(filename).remove();
    cd.rebuildFilenameList();
    theLastNonOutputFilename = testFilename();
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.renameFile = (oldFilename, newFilename) => {
    // This should restore the caret/cursor/selection
    cd.saveCodeFromIndividualSyntaxHighlightEditor(oldFilename);
    const oldFile = cd.fileContentFor(oldFilename);
    const content = oldFile.val();
    cd.deleteFile(oldFilename);
    cd.newFile(newFilename, content);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.editorRefocus = () => {
    cd.loadFile(cd.currentFilename());
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.radioEntrySwitch = (previous, current) => {
    // Used in test-page, setup-page, and history/diff-dialog
    if (previous != undefined) {
      previous.removeClass('selected');
    }
    current.addClass('selected');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.fileContentFor = (filename) => {
    return jqElement('file_content_for_' + filename);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const jqElement = (name) => {
    return $('[id="' + name + '"]');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const fileDiv = (filename) => {
    return jqElement(filename + '_div');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const makeNewFile = (filename, content) => {
    const div = $('<div>', {
      'class': 'filename_div',
      id: filename + '_div'
    });
    const text = $('<textarea>', {
      'class': 'file_content',
      'spellcheck': 'false',
      'data-filename': filename,
      name: 'file_content[' + filename + ']',
      id: 'file_content_for_' + filename
      //wrap: 'off'
    });
    // For some reason, setting wrap cannot be done as per the
    // commented out line above... when you create a new file in
    // FireFox 17.0.1 it still wraps at the textarea width.
    // So instead I do it like this, which works in FireFox?!
    text.attr('wrap', 'off');

    text.val(content);
    div.append(text);

    return div;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const testFilename = () => {
    const filenames = cd.filenames();
    return filenames[testFilenameIndex(filenames)];
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const testFilenameIndex = (filenames) => {
    // When starting and in file-knave navigation
    // the current file is sometimes not present.
    // (eg the file has been renamed/deleted).
    // When this happens, try to select a test file.
    for (let i = 0; i < filenames.length; i++) {
      const parts = filenames[i].toLowerCase().split('/');
      const filename = parts[parts.length - 1];
      if (filename.search('test') !== -1) {
        return i;
      }
    }
    return 0;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const setRenameAndDeleteButtons = (filename) => {
    const fileOps = $('#file-operations');
    const   newFile  = fileOps.find('#new');
    const renameFile = fileOps.find('#rename');
    const deleteFile = fileOps.find('#delete');
    const disable = (node) => { node.prop('disabled', true ); };
    const enable  = (node) => { node.prop('disabled', false); };

    if (cantBeRenamedOrDeleted(filename)) {
      disable(renameFile);
      disable(deleteFile);
    } else {
      enable(renameFile);
      enable(deleteFile);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const cantBeRenamedOrDeleted = (filename) => {
    const filenames = [ 'cyber-dojo.sh', 'output' ];
    return cd.inArray(filename, filenames);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const selectFileInFileList = (filename) => {
    // Can't do $('radio_' + filename) because filename
    // could contain characters that aren't strictly legal
    // characters in a dom node id so I do this instead...
    const node = $('[id="radio_' + filename + '"]');
    const previousFilename = cd.currentFilename();
    const previous = $('[id="radio_' + previousFilename + '"]');
    cd.radioEntrySwitch(previous, node);
    setRenameAndDeleteButtons(filename);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
