module.exports = {
  transpileDependencies: ["vuetify"],
  configureWebpack: {
    module: {
      rules: [{test: /\.md$/, use: "raw-loader"}],
    },
  },
};
