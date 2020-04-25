import Vue from 'vue';
import VueRouter from 'vue-router';

Vue.use(VueRouter);

// Components
import Home from './components/home/Home';
import Create from './components/create/Create';
import List from './components/list/List';
import View from './components/view/View';
import MyPuzzles from './components/user/MyPuzzles';
import Verify from './components/verify/Verify';
// Routes
const router = new VueRouter({
  mode: 'history',
  base: __dirname,
  routes: [
    { name: 'home', path: '/', component: Home },
    { name: 'puzzles', path: '/puzzles', component: List },
    { name: 'creator', path: '/puzzle/create', component: Create },
    { path: '/puzzle/:id', component: View },
    { path: '/my-puzzles', component: MyPuzzles },
    { path: '/verify', component: Verify },
    { path: '/verify/:id', component: Verify }
  ]
});

new Vue({
  router,
  template:`<router-view></router-view>`,
  mounted: async function () {
    console.log('App mounted');
  }
}).$mount('#app');