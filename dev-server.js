var WebpackDevServer = require('webpack-dev-server');
var webpack = require('webpack');
var config = require('./webpack.config.js');
var path = require('path');

var compiler = webpack(config);
var server = new WebpackDevServer(compiler, {
  hot: true,
  filename: config.output.filename,
  publicPath: config.output.publicPath,
  historyApiFallback: true,
  stats: {
    colors: true
  }
});
server.listen(9010, 'localhost', function() {});
