<template>
  <v-container>
    <VueShowdown :markdown="fileContent" flavor="github"></VueShowdown>
  </v-container>
</template>

<script>
import VueShowdown from "vue-showdown";

export default {
  name: "Lab_1_Kubernetes",
  components: VueShowdown,
  data: function () {
    return {
      fileContent: null,
      fileToRender:
        "https://raw.githubusercontent.com/ThinkportRepo/big-data-on-k8s-workshop/main/2_lab/exercises/1_Kubernetes/README.md",
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
      this.fileContent = "pulling Readme from Github ... ";

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
<style scoped>
.custom {
  color: red;
  background-color: blue;
}

img {
  padding-left: 50px;
}
h2 {
  padding-bottom: 30px;
  padding-top: 20px;
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
