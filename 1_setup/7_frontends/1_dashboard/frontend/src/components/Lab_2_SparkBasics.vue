<template>
  <v-container>
    <v-progress-linear
      v-if="serverOutputStatus"
      indeterminate
      color="cyan"
      height="25"
      >loading Basic Spark exercises ...</v-progress-linear
    >
    <VueShowdown
      v-else
      :markdown="fileContent.sparkbasics"
      flavor="github"></VueShowdown>
  </v-container>
</template>

<script>
import VueShowdown from "vue-showdown";
import * as socketio from "@/plugins/socketio";

export default {
  name: "Lab_2_SparkBasics",
  components: VueShowdown,
  data: function () {
    return {
      fileContent: null,
      serverOutputStatus: true,
    };
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
