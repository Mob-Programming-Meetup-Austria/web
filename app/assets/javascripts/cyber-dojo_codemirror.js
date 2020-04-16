/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  let colour = 'colour';  // 'colour' || ''
  let theme = 'dark';     // 'dark' || 'light'

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // 4 CodeMirror css themes are called
  // o) dark
  // o) dark-colour
  // o) light
  // o) light-colour

  cd.setupThemeColourButtonsClickHandlers = (theme,colour) => {
    setupThemeButton(theme);
    setupColourButton(colour);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const setupThemeButton = (theme) => {
    switch (theme) {
      case 'dark':
        setThemeTo('dark');
        cd.themeButton().clickToggle(setThemeLight, setThemeDark);
        break;
      case 'light':
        setThemeTo('light');
        cd.themeButton().clickToggle(setThemeDark, setThemeLight);
        break;
    }
    cd.themeButton().show();
  };

  const setThemeDark  = () => {
    setThemeTo('dark');
    ajaxSetTheme('dark');
  };
  const setThemeLight = () => {
    setThemeTo('light');
    ajaxSetTheme('light');
  };

  const setThemeTo = (newTheme) => {
    theme = newTheme;
    runActionOnAllCodeMirrorEditors(setTheme);
  };

  const ajaxSetTheme = (theme) => {
    $.ajax({
      type:'POST',
       url:'/kata/setTheme',
      data:{ id:cd.kataId(), value:theme }
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const setupColourButton = (colour) => {
    switch (colour) {
      case 'on':
        setColourTo('colour');
        cd.colourButton().clickToggle(setColourOff, setColourOn);
        break;
      case 'off':
        setColourTo('');
        cd.colourButton().clickToggle(setColourOn, setColourOff);
        break;
    }
    cd.colourButton().show();
  };

  const setColourOn   = () => {
    setColourTo('colour');
    ajaxSetColour('on');
  };
  const setColourOff  = () => {
    setColourTo('');
    ajaxSetColour('off');
  };

  const setColourTo = (newColour) => {
    colour = newColour;
    runActionOnAllCodeMirrorEditors(setTheme);
  };

  const ajaxSetColour = (onOff) => {
    $.ajax({
      type:'POST',
       url:'/kata/setColour',
      data:{ id:cd.kataId(), value:onOff }
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const setTheme = (editor) => {
    editor.setOption('theme', codeMirrorTheme());
    editor.setOption('smartIndent', codeMirrorSmartIndent());
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.switchEditorToCodeMirror = (filename) => {
    const textArea = document.getElementById(`file_content_for_${filename}`);
    const parent = textArea.parentNode;
    const editor = CodeMirror(parent, editorOptions(filename));

    textArea.style.display = 'none';
    editor.cyberDojoTextArea = textArea;
    editor.setValue(textArea.value);

    editor.getWrapperElement().id = syntaxHighlightFileContentForId(filename);
    bindHotKeys(editor);

    if (!codeMirrorIndentWithTabs(filename)) {
      editor.addKeyMap({
        Tab: (cm) => {
          if (cm.somethingSelected()) {
            cm.indentSelection('add');
          } else {
            cm.execCommand('insertSoftTab');
          }
        }
      }, true);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.focusSyntaxHighlightEditor = (filename) => {
    const element = document.getElementById(syntaxHighlightFileContentForId(filename));
    if (element !== null) {
      setTheme(element.CodeMirror);
      element.CodeMirror.refresh();
      element.CodeMirror.focus();
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.saveCodeFromSyntaxHighlightEditors = () => {
    $.each($('.CodeMirror'), (i, editorDiv) => {
      editorDiv.CodeMirror.cyberDojoTextArea.value = editorDiv.CodeMirror.getValue();
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.saveCodeFromIndividualSyntaxHighlightEditor = (filename) => {
    const editorDiv = document.getElementById(syntaxHighlightFileContentForId(filename));
    editorDiv.CodeMirror.cyberDojoTextArea.value = editorDiv.CodeMirror.getValue();
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const editorOptions = (filename) => {
    return {
         lineNumbers: true,
       matchBrackets: true,
          indentUnit: cd.syntaxHighlightTabSize,
             tabSize: cd.syntaxHighlightTabSize,
            readOnly: cd.isOutputFile(filename),
      indentWithTabs: codeMirrorIndentWithTabs(filename),
               theme: codeMirrorTheme(),
         smartIndent: codeMirrorSmartIndent(),
                mode: codeMirrorMode(filename),
    };
  };

  const codeMirrorIndentWithTabs = (filename) => {
    return filename.toLowerCase() === 'makefile';
  };

  const codeMirrorTheme = () => {
    const inColour = (colour === '') ? '' : '-colour';
    return 'cyber-dojo-' + theme + inColour;
  };

  const codeMirrorSmartIndent = () => colour !== '';

  const codeMirrorMode = (filename) => {
    filename = filename.toLowerCase();
    if (filename === 'makefile') {
      return 'text/x-makefile';
    }
    switch (fileExtension(filename)) {
      // C/C++ have split source
      case '.c'      : return 'text/x-csrc';
      case '.cpp'    : return 'text/x-c++src';
      case '.hpp'    : return 'text/x-c++hdr';
      case '.h'      : return 'text/x-c++hdr';
      // all the rest don't
      case '.clj'    : return 'text/x-clojure';
      case '.coffee' : return 'text/x-coffeescript';
      case '.cs'     : return 'text/x-csharp';
      case '.d'      : return 'text/x-d';
      case '.feature': return 'text/x-feature';
      case '.go'     : return 'text/x-go';
      case '.groovy' : return 'text/x-groovy';
      case '.htm'    : return 'text/html';
      case '.html'   : return 'text/html';
      case '.hs'     : return 'text/x-haskell';
      case '.java'   : return 'text/x-java';
      case '.js'     : return 'text/javascript';
      case '.md'     : return 'text/x-markdown';
      case '.php'    : return 'text/x-php';
      case '.py'     : return 'text/x-python';
      case '.rb'     : return 'text/x-ruby';
      case '.rs'     : return 'text/x-rustsrc';
      case '.scala'  : return 'text/x-scala';
      case '.sh'     : return 'text/x-sh';
      case '.swift'  : return 'text/x-swift';
      case '.vb'     : return 'text/x-vb';
      case '.vhdl'   : return 'text/x-vhdl';
      case '.xml'    : return 'text/xml';
    }
    return '';
  };

  const fileExtension = (filename) => {
    const lastPoint = filename.lastIndexOf('.');
    if (lastPoint === -1) {
      return '';
    } else {
      return filename.substring(lastPoint);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const syntaxHighlightFileContentForId = (filename) => {
    return `syntax_highlight_file_content_for_${filename}`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const runActionOnAllCodeMirrorEditors = (action) => {
    $.each($('.CodeMirror'), (_i, editorDiv) => {
      action(editorDiv.CodeMirror);
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const bindHotKeys = (editor) => {
    editor.setOption('extraKeys', {
      'Alt-T': () => $('#test-button').click(),
      'Alt-J': () => cd.loadNextFile(),
      'Alt-K': () => cd.loadPreviousFile(),
      'Alt-O': () => cd.toggleOutputFile()
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
