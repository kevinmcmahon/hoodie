import Vue from 'vue';
import Router from 'vue-router';
import Home from '@/views/Home';
import Location from '@/views/Location';

Vue.use(Router);

export default new Router({
    mode: 'history',
    routes: [
        {
            path: '/',
            name: 'home',
            component: Home
        },
        {
            path: '/location',
            name: 'location',
            component: Location
        }
    ]
});
