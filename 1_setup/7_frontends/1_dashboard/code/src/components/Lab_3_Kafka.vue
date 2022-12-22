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
        "https://raw.githubusercontent.com/alexortner/kubernetes-on-raspberry-pi/main/README.md",
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
      this.fileContent = "rendering ";
      // var self;
      this.$http.get(this.fileToRender).then(
        (response) => {
          // get body data

          this.fileContent = response.body;
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
