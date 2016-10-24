const path = require("path")

module.exports = {
  context: path.join(__dirname, "coffee"),
  devtool: "inline-source-map",
  entry: {
    client: "./client.coffee"
  },
  output: {
    path: path.join(__dirname, "src/public/js"),
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
        exclude: /node_modules/,
        loader: "babel-loader"
      },
      {
        test: /\.sass$/,
        exclude: /node_modules/,
        loaders: ["style", "css", "sass"]
      }
    ]
  }
}
