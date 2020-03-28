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
        <span class="mr-2">Latest Release</span>
        <v-icon>mdi-open-in-new</v-icon>
      </v-btn>
    </v-app-bar>
    <v-content>
      <router-view />
    </v-content>
    <Footer />
  </v-app>
</template>

<script>
import Footer from '@/views/Footer';
export default {
  name: 'App',

  components: {
    Footer
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
</style>
