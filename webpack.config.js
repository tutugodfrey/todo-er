const path = require('path');
const webpack = require('webpack');
const dotenv = require('dotenv-safe');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = (env) => {
  // const env = dotenv.config().parsed;
  const envKeys = Object.keys(env).reduce((prev, next) => {
    prev[`process.env.${next}`] = JSON.stringify(env[next]);
    return prev;
  }, {});
  console.log(env)
  // const envKeys = env
  console.log(envKeys, 'envKeys')
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
        }, {
          test: /\.(png|jpg|jpeg)$/,
          use: [{
            loader: 'url-loader',
            options: { limit: 3000000 },
          }],
        },
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
    plugins: [
      new HtmlWebpackPlugin({
        template: path.resolve('./client/index.html')
      }),
      new webpack.DefinePlugin(envKeys),
    ]
  }
}
