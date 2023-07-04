<template>
  <v-container>
    <v-progress-linear
      v-if="serverOutputStatus"
      indeterminate
      color="cyan"
      height="25"
      >loading Kafka exercises ...</v-progress-linear
    >
    <VueShowdown
      v-else
      :markdown="fileContent.kafka"
      flavor="github"></VueShowdown>
    <v-btn
      v-if="showMessage"
      density="comfortable"
      v-on:click="show_solution"
      >{{ solutionShowButtonText }}</v-btn
    >
  </v-container>
</template>

<script>
import VueShowdown from "vue-showdown";
import * as socketio from "@/plugins/socketio";

export default {
  name: "Lab_3_Kafka",
  components: VueShowdown,
  data: function () {
    return {
      fileContent: null,
      serverOutputStatus: true,
      solutionHiddenState: true,
      solutionShowButtonText: "Lösungen einblenden",
      showMessage: false,
    };
  },
  created() {
    setTimeout(() => {
      this.showMessage = true;
    }, 10000); // 10 seconds delayed
  },
  mounted() {
    socketio.addEventListener({
      type: "lab",
      callback: (message) => {
        this.fileContent = message;
        this.serverOutputStatus = false;
      },
    });
  },
  methods: {
    show_solution: function () {
      const details = document.getElementsByClassName("solution");
      let newSolutionHiddenState = true;
      if (this.solutionHiddenState == false) {
        newSolutionHiddenState = true;
        this.solutionHiddenState = true;
        this.solutionShowButtonText = "Lösungen einblenden";
      } else {
        newSolutionHiddenState = false;
        this.solutionHiddenState = false;
        this.solutionShowButtonText = "Lösungen ausblenden";
      }
      for (const box of details) {
        box.hidden = newSolutionHiddenState;
      }
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
