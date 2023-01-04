<template>
  <div id="app"><VueShowdown :markdown="fileContent"></VueShowdown></div>
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
      gitUser: "alexortner",
      gitToken:
        "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",
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
        headers: {
          Authorization:
            "Basic YWxleG9ydG5lcjpnaXRodWJfcGF0XzExQUQ2S0taQTBtdWxsOTEzaTlzb1NfWUN3TGJoWk5ETFpIcGxzZWVGcFJXY0Zhdmcwa0J2VTlRTzlOU0QwN1ZubjVCT0FQTVRTQ0x0S0tHeWU=",
        },
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
