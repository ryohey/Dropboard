const path = require("path")
const nodeExternals = require("webpack-node-externals")

module.exports = {
  target: "node",
  externals: [nodeExternals()],
  context: path.join(__dirname, "coffee"),
  devtool: "inline-source-map",
  entry: {
    server: "./server.coffee"
  },
  output: {
    path: path.join(__dirname, "src"),
    filename: "[name].js"
  },
  module: {
    loaders: [
      { 
        test: /\.coffee$/,
        exclude: /node_modules/,
        loader: "coffee-loader"
      },
      {
        test: /\.js$/,
        loader: "babel-loader",
        exclude: /node_modules/
      },
      { // for body-parser
        test: /\.json$/, 
        loader: "json-loader"
      },
      { 
        test: /\.ejs$/, 
        loader: "ejs-loader?variable=data"
      }
    ]
  }
}
