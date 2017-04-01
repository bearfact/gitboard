const path = require('path');
const webpack = require('webpack');

const DEVELOPMENT = process.env.NODE_ENV === 'development';
const PRODUCTION = process.env.NODE_ENV === 'production';

const entry = PRODUCTION
  ? ['./app/assets/index.coffee']
  : [
      './app/assets/index.coffee',
      'webpack/hot/dev-server',
      'webpack-dev-server/client?http://localhost:9010'
    ]

var common_plugins = [
  new webpack.HotModuleReplacementPlugin()
]
const plugins =  PRODUCTION
  ? common_plugins.concat([new webpack.optimize.UglifyJsPlugin({compress: { warnings: false }}) ])
  : common_plugins

module.exports = {
  entry: entry,
  plugins: plugins,
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'ng-annotate-loader', 'coffee-loader' ]
      },
      {
        test: /\.css$/,
        use: [ 'style-loader', 'css-loader' ]
      },
      {
       test: /.*\.scss$/,
       loaders: ['style-loader', 'css-loader', 'sass-loader']
      },
      {
        test: /\.(png|jpg|jpeg|gif|svg|woff|woff2|ttf|eot)$/,
        loader: 'file-loader',
        options: {
          name: '[name].[ext]?[hash]'
        }
      },
      {
        test: /\.html$/,
        use: 'raw-loader'
      }
    ]
  },
  output: {
    path: path.join(__dirname, 'public/dist'),
    publicPath: '/dist/',
    filename: 'bundle.js'
  }
};
