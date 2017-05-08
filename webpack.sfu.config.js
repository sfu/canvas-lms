/* eslint import/no-commonjs: "off" */
if (!process.env.NODE_ENV) process.env.NODE_ENV = 'development'

const path = require('path')
require('babel-polyfill')

module.exports = {
  devtool: process.env.NODE_ENV === 'production' ? undefined : 'eval',
  entry: {
    copyright_notice_modal_dialog: path.resolve(__dirname, 'public/javascripts/sfu-modules/copyright_notice_modal_dialog.js'),
    google_docs_pia_notice: path.resolve(__dirname, 'public/javascripts/sfu-modules/google_docs_pia_notice.js'),
  },
  output: {
    path: path.resolve(__dirname, 'public/dist/sfu'),
    pathinfo: true,
    filename: '[name].js'
  },
  resolve: {
    alias: {
      jsx: path.resolve(__dirname, './app/jsx')
    },
    extensions: ['.js']
  },
  // externals: {
  //   jquery: 'jQuery',
  //   react: 'React',
  //   'react-dom': 'ReactDOM'
  // },
  module: {
    rules: [
      {
        test: /\.js$/,
        loaders: ['babel-loader']
      },
      {
        test: require.resolve('./public/javascripts/vendor/jquery-1.7.2'),
        loader: 'exports-loader?window.jQuery'
      },
    ]
  }
}
