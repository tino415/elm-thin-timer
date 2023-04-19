import { Elm } from './Main.elm';
import {
  initAuth,
  initThinBackend,
  getCurrentUser,
  getCurrentUserId
} from 'thin-backend';

import {init} from './thin-backend';


async function main() {
  await initThinBackend({ host: process.env.BACKEND_URL });
  await initAuth()

  const $root = document.createElement('div');
  document.body.appendChild($root);

  getCurrentUser().then(user => {
    const app = Elm.Main.init({
      node: $root,
      flags: user,
    });

    init(app)
  })
}

main()
