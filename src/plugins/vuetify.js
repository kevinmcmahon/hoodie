import Vue from 'vue';
import Vuetify from 'vuetify/lib';

Vue.use(Vuetify);

export default new Vuetify({
    theme: {
        themes: {
            light: {
                primary: '#B3DDF2',
                secondary: '#259eda',
                accent: '#FF0000'
            }
        }
    }
});
