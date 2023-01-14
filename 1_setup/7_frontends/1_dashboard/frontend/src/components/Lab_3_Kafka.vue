<template>
  <div id="app">
    <h1 v-mystyle>Sucker</h1>
    <VueShowdown v-default-classes :markdown="fileContent"></VueShowdown>
  </div>
</template>

<script>
import VueShowdown from "vue-showdown";

export default {
  name: "App",
  components: VueShowdown,
  data: function () {
    return {
      fileContent: null,
      fileToRender:
        "https://raw.githubusercontent.com/ThinkportRepo/big-data-on-k8s-workshop/main/2_lab/exercises/3_Kafka/README.md",
      rawContent: null,
    };
  },
  created: function () {
    //  const fileToRender = `./assets/documentation/general/welcome.md`;
    //const rawContent = ""; // Read the file content using fileToRender
    // this.fileContent = "### marked(rawContent) should get executed";
    this.getContent();
  },
  methods: {
    getContent() {
      this.fileContent = "pulling Markdown from github ... ";

      var options = {
        url: this.fileToRender,
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
          this.fileContent = "An error ocurred";
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
/* CSS Simple Pre Code */
pre {
  background: #333;
  border: 1px solid #ddd;
  border-left: 5px solid #f36d33;
  color: #666;
  page-break-inside: avoid;
  font-family: monospace;
  font-size: 15px;
  line-height: 1.6;
  margin-bottom: 1.6em;
  max-width: 80%;
  overflow: auto;
  padding: 1em 1.5em;
  display: block;
  word-wrap: break-word;
  white-space: pre;
}

pre.code {
  margin: 0px 0px;
  padding: 0px;
  position: relative;
  color: #e7e8ee !important;
  background-color: rgba(0, 0, 0, 0);
}

code {
  margin: 0px 0px;
  padding: 0px;
  position: relative;
  color: #647dd9 !important;
  background-color: rgba(184, 38, 38, 0);
}
</style>
