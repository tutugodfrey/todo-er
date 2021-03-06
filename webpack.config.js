const path = require('path');
const webpack = require('webpack');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const dotenv = require('dotenv-safe');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = () => {
  const env = dotenv.config().parsed;
  const envKeys = Object.keys(env).reduce((prev, next) => {
    prev[`process.env.${next}`] = JSON.stringify(env[next]);
    return prev;
  }, {});

  return {
    devtool: 'inline-source-map',
    entry: './client/index.js',
    output: {
      path: path.join(__dirname, 'public'),
      filename: 'bundle.js',
      publicPath: '/',
    },
    module: {
      rules: [
        {
          test: /\.(js|jsx)$/,
          use: ['babel-loader'],
          exclude: /node_modules/,
        }, {
          test: /\.(scss|sass)$/,
          exclude: /ndoe_modules/,
          use: ['style-loader', 'css-loader?url=false', 'sass-loader']
        }
      ]
    },
    devServer: {
      inline: true,
      port: 3000,
      historyApiFallback: true
    },
    resolve: {
      extensions: ['.js', '.jsx']
    },
    optimization: {
      minimizer: [
        // we specify a custom UglifyJsPlugin here to get source maps in production
        new UglifyJsPlugin({
          cache: true,
          parallel: true,
          uglifyOptions: {
            compress: false,
            ecma: 6,
            mangle: true
          },
          sourceMap: true
        })
      ]
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: path.resolve('./client/index.html')
      }),
      new webpack.DefinePlugin(envKeys),
    ]
  }
}
