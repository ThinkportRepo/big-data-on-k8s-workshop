<template>
  <v-card class="mx-auto" max-width="344" outlined>
    <v-list-item three-line>
      <v-list-item-avatar tile size="80">
        <v-img class="elevation-6" alt="" :src="imageURLS.jupyter"></v-img>
      </v-list-item-avatar>

      <v-list-item-content>
        <v-list-item-title class="text-h5 mb-1">
          {{ title }}
        </v-list-item-title>
        <v-list-item-subtitle>{{ text }}</v-list-item-subtitle>
      </v-list-item-content>
    </v-list-item>

    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn outlined rounded text :href="url" target="_blank">
        {{ url_label }} <v-icon>mdi-open-in-new</v-icon></v-btn
      >
    </v-card-actions>
  </v-card>
</template>
<script>
export default {
  name: "Card",
  props: {
    title: String,
    text: String,
    url_label: String,
    url: String,
    imageURL: String,
  },
  data: () => ({
    imageURLS: {
      jupyter: "@/assets/jupyter_logo.png",
      zeppelin: "@/assets/zeppelin_classic_logo.png",
    },
  }),
};
</script>
