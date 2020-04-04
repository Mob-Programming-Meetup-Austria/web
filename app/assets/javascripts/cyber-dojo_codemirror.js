/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  const darkColourTheme  = 'cyber-dojo-dark-colour';
  const lightColourTheme = 'cyber-dojo-light-colour';
  const darkTheme        = 'cyber-dojo-dark';
  const lightTheme       = 'cyber-dojo-light';

  let codeMirrorTheme = darkTheme;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.darkColourThemeButtonHtml = () => {
    const titleWords = ['set','theme','to','dark','+','colour'];
    return themeButtonHtml(darkColourTheme, titleWords);
  };
  cd.lightColourThemeButtonHtml = () => {
    const titleWords = ['set','theme','to','light','+','colour'];
    return themeButtonHtml(lightColourTheme, titleWords);
  };
  cd.darkThemeButtonHtml = () => {
    const titleWords = ['set','theme','to','dark'];
    return themeButtonHtml(darkTheme, titleWords);
  };
  cd.lightThemeButtonHtml = () => {
    const titleWords = ['set','theme','to','light'];
    return themeButtonHtml(lightTheme, titleWords);
  };

  const themeButtonHtml = (theme, words) => {
    const title = words.join('&nbsp');
    const disabled = (codeMirrorTheme === theme) ? 'disabled' : '';
    return `<button type="button" id="${theme}"` +
      `onClick="cd.setThemeFrom(this.id);" ${disabled}>${title}</button>`;
  };

  cd.setThemeFrom = (theme) => {
    codeMirrorTheme = theme;
    runActionOnAllCodeMirrorEditors(setTheme);
    enableAllThemeButtons();
    const disableButton  = () => $(`#${theme}`).attr('disabled', true);
    disableButton();
  };

  const setTheme = (editor) => {
    editor.setOption('theme', codeMirrorTheme);
    editor.setOption('smartIndent', codeMirrorSmartIndent());
  };

  const enableAllThemeButtons = () => {
    const enable = (id) => $(`#${id}`).attr('disabled', false);
    enable(darkColourTheme);
    enable(lightColourTheme);
    enable(darkTheme);
    enable(lightTheme);
  };

  const codeMirrorSmartIndent = () => {
    switch (codeMirrorTheme) {
    case darkColourTheme : return true;
    case lightColourTheme: return true;
    case darkTheme       : return false;
    case lightTheme      : return false;
    default: //error
    }
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
                mode: codeMirrorMode(filename),
          indentUnit: cd.syntaxHighlightTabSize,
             tabSize: cd.syntaxHighlightTabSize,
      indentWithTabs: codeMirrorIndentWithTabs(filename),
               theme: codeMirrorTheme,
            readOnly: cd.isOutputFile(filename),
         smartIndent: codeMirrorSmartIndent()
    };
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  const codeMirrorIndentWithTabs = (filename) => {
    return filename.toLowerCase() === 'makefile';
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
