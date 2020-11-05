/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.setupAvatarNameHoverTip = ($element, textBefore, avatarIndex, textAfter) => {
    cd.setTip($element, () => {
      $.getJSON('/images/avatars/names.json', '', (avatarsNames) => {
        const avatarName = avatarsNames[avatarIndex];
        const tip = `${textBefore}${avatarName}${textAfter}`;
        cd.showHoverTip($element, tip);
      });
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.setupTrafficLightTip = ($light, kataId, wasIndex, nowIndex, options) => {
    cd.setTip($light, () => {
      const args = `id=${kataId}&was_index=${wasIndex}&now_index=${nowIndex}`;
      $.getJSON(`/differ/diff_summary?${args}`, '', (summary) => {
        cd.showHoverTip($light, tipHtml($light, summary, options));
      });
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  const tipHtml = ($light, diffSummary, options) => {
    const avatarIndex = $light.data('avatar-index');
    const colour = $light.data('colour');
    const number = $light.data('number');
    return `<table>
             <tr>
               <td>${avatarImage(avatarIndex)}</td>
               <td><span class="traffic-light-count ${colour}">${number}</span></td>
               <td><img src="/images/traffic-light/${colour}.png"
                      class="traffic-light-diff-tip-traffic-light-image"></td>
             </tr>
           </table>
           ${diffLinesHtmlTable(diffSummary, options)}`;
  };

  // - - - - - - - - - - - - - - - - - - - -

  const avatarImage = (avatarIndex) => {
    if (avatarIndex === '') {
      return '';
    } else {
      return `<img src="/images/avatars/${avatarIndex}.jpg"
                 class="traffic-light-diff-tip-avatar-image">`;
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  const diffLinesHtmlTable = (diffs, options) => {
    const $table = $('<table>', { class:'filenames' });

    options ||= {};
    showUnchangedFiles = options.showUnchangedFiles; // default == false
    showSameLineCounts = options.showSameLineCounts; // default == false

    const somethingChanged = diffs.filter(diff => diff.type != 'unchanged').length > 0;
    //cyber-dojo.sh cannot be deleted so there is always one file
    if (somethingChanged || showUnchangedFiles) {
      const $tr = $('<tr>');
      $tr.append($linesCountIcon('deleted', '&mdash;'));
      $tr.append($linesCountIcon('added', '+'));
      if (showSameLineCounts) {
        $tr.append($linesCountIcon('same', '='));
      }
      $tr.append($('<td>'));
      $tr.append($('<td>'));
      $table.append($tr);
    }

    const filenames = diffs.map(diff => diffFilename(diff));
    cd.sortedFilenames(filenames).forEach(filename => {
      const file = diffs.find(diff => diffFilename(diff) === filename);
      const $tr = $('<tr>');
      if (file.type != 'unchanged' || showUnchangedFiles) {
        $tr.append($lineCount('deleted', file));
        $tr.append($lineCount('added', file));
        if (showSameLineCounts) {
          $tr.append($lineCount('same', file));
        }
        $tr.append($diffType(file));
        $tr.append($diffFilename(file));
      }
      $table.append($tr);
    });
    return $table.get(0).outerHTML;
  };

  // - - - - - - - -

  const $linesCountIcon = (type, glyph) => {
    const $icon = $('<div>', { class:`diff-line-count-icon ${type}` }).html(glyph);
    return $('<td>').append($icon);
  };

  // - - - - - - - -

  const $lineCount = (type, file) => {
    const $count = $('<div>', {
      class:`diff-${type}-line-count`,
      disabled:"disabled"
    });
    $count.html(nonZero(file.line_counts[type]));
    return $('<td>').append($count);
  };

  const nonZero = (n) => {
    return n > 0 ? n : '&nbsp;';
  };

  // - - - - - - - -

  const $diffType = (diff) => {
    return $('<td>').append($('<div>', {
      class:`diff-type-marker ${diff.type}`
    }));
  };

  // - - - - - - - -

  const $diffFilename = (diff) => {
    const $filename = $('<div>', { class:`diff-filename ${diff.type}` });
    $filename.text(diffFilename(diff));
    return $('<td>').append($filename);
  };

  const diffFilename = (diff) => {
    if (diff.type === 'deleted') {
      return diff.old_filename;
    } else {
      return diff.new_filename;
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.setupHoverTips = function(nodes) {
    nodes.each(function() {
      const node = $(this);
      const setTipCallBack = () => {
        const tip = node.data('tip');
        if (tip === 'traffic_light_count') {
          cd.showHoverTip(node, trafficLightCountHoverTip(node));
        } else {
          cd.showHoverTip(node, tip);
        }
      };
      cd.setTip(node, setTipCallBack);
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  const trafficLightCountHoverTip = (node) => {
    // for dashboard avatar totalCount
    const reds = node.data('red-count');
    const ambers = node.data('amber-count');
    const greens = node.data('green-count');
    const timeOuts = node.data('timed-out-count');
    const tr = (s) => `<tr>${s}</tr>`;
    const td = (s) => `<td>${s}</td>`;
    const trLight = (colour, count) => {
      return tr(td('<img' +
                   " class='traffic-light-diff-tip-traffic-light-image'" +
                   ` src='/images/traffic-light/${colour}.png'>`) +
                td(`<div class='traffic-light-diff-tip-tag ${colour}'>` +
                   count +
                   '</div>'));
    };
    let html = '';
    html += '<table>';
    html += trLight('red', reds);
    html += trLight('amber', ambers);
    html += trLight('green', greens);
    if (timeOuts > 0) {
      html += trLight('timed_out', timeOuts);
    }
    html += '</table>';
    return html;
  };

  // - - - - - - - - - - - - - - - - - - - -

  const hoverTipContainer = () => {
    return $('#hover-tip-container');
  };

  cd.setTip = (node, setTipCallBack) => {
    // The speed of the mouse could easily exceed
    // the speed of the getJSON callback...
    // The mouse-has-left attribute caters for this.
    node.mouseenter(() => {
      node.removeClass('mouse-has-left');
      setTipCallBack(node);
    });
    node.mouseleave(() => {
      node.addClass('mouse-has-left');
      hoverTipContainer().empty();
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.createTip = (element, tip, where) => {
    cd.setTip(element, () => {
      cd.showHoverTip(element, tip, where);
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.showHoverTip = (node, tip, where) => {
    if (where === undefined) {
      where = {};
    }
    if (where.my === undefined) { where.my = 'top'; }
    if (where.at === undefined) { where.at = 'bottom'; }
    if (where.of === undefined) { where.of = node; }

    if (!node.attr('disabled')) {
      if (!node.hasClass('mouse-has-left')) {
        // position() is the jQuery UI plug-in
        // https://jqueryui.com/position/
        const hoverTip = $('<div>', {
          'class': 'hover-tip'
        }).html(tip).position({
          my: where.my,
          at: where.at,
          of: where.of,
          collision: 'flip'
        });
        hoverTipContainer().html(hoverTip);
      }
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
