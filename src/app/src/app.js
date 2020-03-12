import Vue from 'vue';
import VueRouter from 'vue-router';

Vue.use(VueRouter);

// Components
import Home from './components/home/Home';
import Create from './components/create/Create';
import List from './components/list/List';
// import View from './components/view/View';
// import Solve from './components/solve/Solve'
// import Claim from './components/claim/Claim';

// Routes
const router = new VueRouter({
  // mode: 'history',
  // base: __dirname,
  routes: [
    { name: 'home', path: '/', component: Home },
    { name: 'puzzles', path: '/puzzles', component: List },
    { name: 'creator', path: '/puzzle/create', component: Create }//,
    // { path: '/puzzle/:id', component: View },
    // { path: '/puzzle/submit/:id', component: Solve },
    // { path: '/puzzle/claim/:id', component: Claim }
  ]
});

new Vue({
  router,
  template:`<router-view></router-view>`,
  mounted: async function () {
    console.log('App mounted');
  }
}).$mount('#app');