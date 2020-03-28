<template>
  <v-app>
    <v-app-bar
      app
      color="primary"
      dark
    >
      <v-btn
      href="/"
      text>
      <div class="d-flex align-center">
        <v-img
          alt="Chicago Flag Star"
          class="shrink mr-3"
          contain
          src="./assets/chicago-star.svg"
          transition="scale-transition"
          width="40"
        />
        <span class="site-title">Hoodie</span>      
      </div>
    </v-btn>
      <v-spacer></v-spacer>
      <v-btn
        href="https://github.com/kevinmcmahon/hoodie/releases/latest"
        target="_blank"
        text
      >
        <span class="mr-2 hoodie-text">Latest Release</span>
        <v-icon>mdi-open-in-new</v-icon>
      </v-btn>
    </v-app-bar>

    <v-content>
      <router-view />
    </v-content>
    <v-footer padless color="primary" dark>
      <v-col
        class="text-center hoodie-text chistar"
        cols="12"
      >
        <strong>Kevin McMahon</strong> CHISTAR {{ new Date().getFullYear() }} 
      </v-col>
  </v-footer>
  </v-app>
</template>

<script>

export default {
  name: 'App',

  components: {
    
  },

  data: () => ({
    //
  }),
};
</script>

<style lang="scss">
  @import '@/sass/variables.scss';
  .hoodie-text {
    font-family: $body-title-family;    
    font-weight: 500;
    text-transform: uppercase
  }
  .site-title {
    display: block;
    font-family: $body-title-family;
    font-style: normal;    
    font-size: 2.5rem;
    font-weight: 700;
    margin: 0;
    text-transform: uppercase
  }
  .chistar {
    font-family: "Big Shoulders Text";
    font-variant-ligatures: discretionary-ligatures;
  }
</style>
