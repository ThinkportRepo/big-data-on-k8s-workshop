<template>
  <v-container>
    <v-row>
      <v-col cols="mb-3">
        <Card
          title="Jupyter"
          text="Notebook for Python & PySpark"
          url_label="Open Jupyter"
          url="https://test.de"
          imgURL="../../assets/jupyter_logo.png"
        ></Card
      ></v-col>
      <v-col cols="mb-3">
        <Card
          title="Zeppelin"
          text="Notebook for Spark (Scala, Python, SQL)"
          url_label="Open Zeppelin"
          url="https://test.de"
          imgURL="../assets/jupyter_logo.png"
        ></Card
      ></v-col>
    </v-row>
    <v-row> </v-row>
  </v-container>
</template>

<script>
import Card from "@/components/Card";
export default {
  name: "Dashboard",
  components: {
    Card,
  },

  data: () => ({}),
};
</script>
