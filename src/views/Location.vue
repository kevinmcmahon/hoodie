<template>
    <div>
        <v-card v-if="lat && lng"
            class="mx-auto my-8"
            max-width="1000">
            <header class="d-flex justify-center py-2" >
                <h1>Location</h1>
            </header>
            <MapboxMap                
                v-bind:lat="lat"
                v-bind:lng="lng"
                style="width:100%; height: 320px;">            
            </MapboxMap>             
        </v-card>
    </div>
</template>

<script>
    import MapboxMap from "@/components/MapboxMap";

    export default {
        name: 'Location',
        components: {
            MapboxMap
        },
        data:  () => ({
            lat: null,
            lng: null
        }),
        mounted: function () {
            this.lat = this.$route.query.lat;
            this.lng = this.$route.query.lng;
        }
    }
</script>

<style lang="sass">

</style>
