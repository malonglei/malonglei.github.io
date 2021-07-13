/* global hexo */

'use strict';

const path = require('path');

// Add comment
hexo.extend.filter.register('theme_inject', injects => {
  let theme = hexo.theme.config;
  if (!theme.gitment.enable) return;

  injects.comment.raw('gitment', '<div id="container"></div>', {}, {cache: true});

  injects.bodyEnd.file('gitment', path.join(hexo.theme_dir, 'layout/_third-party/comments/gitment.swig'));

});
