import { Elm } from './Main.elm';
const Parse = require('parse');

import {init} from './parse';

async function main() {
  Parse.initialize(process.env.APP_ID, process.env.JS_KEY)
  Parse.serverURL = process.env.BACKEND_URL

  const $root = document.createElement('div');
  document.body.appendChild($root);

  const app = Elm.Main.init({
    node: $root,
    flags: null,
  });

  init(app)

  // getCurrentUser().then(user => {
    // const app = Elm.Main.init({
      // node: $root,
      // flags: user,
    // });

    // init(app)
  // })
}

main()
