<template>
  <v-container>
    <VueShowdown :markdown="fileContent" flavor="github"></VueShowdown>
  </v-container>
</template>

<script>
import VueShowdown from "vue-showdown";
// import md_kubernetes from "raw-loader!../../../../../../2_lab/exercises/1_Kubernetes/README.md";
// import exampleText from "../../../../../../2_lab/exercises/1_Kubernetes/README.md";

export default {
  name: "Lab_1_Kubernetes",
  components: VueShowdown,
  data: function () {
    return {
      fileContent: null,
      fileGithubPath:
        "https://raw.githubusercontent.com/ThinkportRepo/big-data-on-k8s-workshop/main/2_lab/exercises/1_Kubernetes/README.md",
      fileLocalPath: "../../../../../../2_lab/exercises/1_Kubernetes/README.md",
      rawContent: null,
    };
  },
  created: function () {
    // use this function to load data from github
    //this.getContent();
    // use this approach with raw loader to read data from local pvc mount
    this.getContentPvc();
  },
  methods: {
    getContentPvc() {
      let path =
        process.env.VUE_APP_GIT_DOKU_BASE_PATH +
        "2_lab/exercises/1_Kubernetes/README.md";
      console.log(path);
      let test = "'@/components/Kubernetes.md";
      console.log(test);
      this.fileContent = require(test).default;
      console.log(this.fileContent);
    },

    getContent() {
      this.fileContent = "pulling Readme from Github ... ";

      var options = {
        url: this.fileGithubPath,
        method: "GET",
      };
      this.$http(options).then(
        (response) => {
          // get body data

          this.fileContent = response.body;
          console.log(this.fileContent);
        },
        (response) => {
          // error callback
          console.log(response);
          this.fileContent = "File not Found! An error ocurred!";
        }
      );
    },
  },
};
</script>
<style>
.custom {
  color: red;
  background-color: blue;
}
h1 {
  padding-bottom: 0.4em;
}
h2 {
  padding-bottom: 0.4em;
  padding-top: 0.3em;
}
/* CSS Simple Pre Code */
pre {
  background: #333;
  border: 1px solid #ddd;
  border-left: 5px solid #00bcd4;
  color: #666;
  page-break-inside: avoid;
  font-family: monospace;
  font-size: 15px;
  line-height: 1.6;
  margin-bottom: 1.6em;
  margin-top: 1.6em;
  max-width: 100%;
  overflow: auto;
  padding: 1em 1.5em;
  display: block;
  word-wrap: break-word;
  white-space: pre;
}

pre code {
  margin: 0px 0px;
  padding: 0px !important;
  font-size: 100% !important;
  position: relative;
  color: #e7e8ee !important;
  background-color: rgba(0, 0, 0, 0) !important;
}

code {
  margin: 0px 0px;
  padding: 0px;
  position: relative;
  color: #647dd9 !important;
}
</style>
