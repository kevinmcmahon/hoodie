<template>
    <v-card class="mx-auto my-6" max-width="1000" min-width="400">
        <v-form class="pa-5 search-text">
            <v-text-field
                v-model="searchQuery"
                label="Enter a Chicago address ..."
                required
            />
        </v-form>
        <v-card-actions>
            <v-spacer/>
            <v-btn class="ma-1 hoodie-btn-text" depressed large color="secondary" @click="searchByAddress()">Look Up Address</v-btn>
            <v-btn class="ma-1 hoodie-btn-text" depressed large color="secondary" @click="searchByLatLng()">Current Location</v-btn>
            <v-spacer/>
        </v-card-actions>
    </v-card>
</template>

<script>
export default {
  name: 'Home',
  data: () => ({
      searchQuery: '',
  }),
  methods: {
    searchByLatLng: async function() {
        this.getLocation(position => { 
            this.$router.push({ path: 'location', query: { lat: position.latitude, lng: position.longitude } });
        });
    },
    searchByAddress: async function() {
        this.$router.push({ path: 'location', query: { address: this.searchQuery }})
    },
    getLocation: function(callback) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
            position => {
                const lat = position.coords.latitude;
                const lng = position.coords.longitude;
                callback({ latitude: lat, longitude: lng });
            },
            err => {
                console.error(err);
                callback(null, err);
            });
        } else {
            console.error("browser doesn't support geolocation");
        }
    }
  }
};
</script>


<style lang="scss">
  @import '@/sass/variables.scss';
  .hoodie-btn-text {    
    font-weight: 700;
  }
</style>
