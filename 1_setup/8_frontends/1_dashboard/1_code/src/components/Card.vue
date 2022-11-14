<template>
  <v-card class="mx-auto" max-width="344" outlined>
    <v-list-item three-line>
      <v-list-item-avatar tile size="80">
        <v-img class="elevation-6 ma-5" alt="" :src="getImgUrl(image)"></v-img>
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
    image: String,
  },
  data: () => ({}),
  methods: {
    getImgUrl(image) {
      console.log(image);
      return require("@/assets/" + image);
    },
  },
};
</script>
