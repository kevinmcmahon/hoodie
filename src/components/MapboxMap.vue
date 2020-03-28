<template>
  <MglMap 
    :accessToken="accessToken"
    :mapStyle="mapStyle"
    :zoom="12"
    :center="[this.lng, this.lat]">        
        <p>
            <MglMarker :coordinates="[this.lng, this.lat]" color="#B3DDF2" />
        </p>        
  </MglMap>
</template>

<script>
import Mapbox from "mapbox-gl";

import { MglMap, MglMarker } from 'vue-mapbox'

export default {
    components: {
        MglMap,
        MglMarker
    }, 
    props: {
        lat: {
            type: Number
        },
        lng: {
            type: Number
        }
    },
    data() {
        return {
            accessToken: process.env.VUE_APP_MAPBOX_API_KEY,
            mapStyle: process.env.VUE_APP_MAP_STYLE,
            coordinates: [],
        };
    },
    created() {
        this.mapbox = Mapbox;
    }
};
</script>
