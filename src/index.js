import { Elm } from './Main.elm';
import {
  initAuth,
  initThinBackend,
  getCurrentUser,
  getCurrentUserId,
  loginWithRedirect,
  logout,
  DataSubscription,
  query
} from 'thin-backend';

const $root = document.createElement('div');
document.body.appendChild($root);


async function main() {
  await initThinBackend({ host: process.env.BACKEND_URL });
  await initAuth()

  getCurrentUser().then(user => {
    console.log('user', user)

    const app = Elm.Main.init({
      node: $root,
      flags: user,
    });

    app.ports.logout.subscribe(_ => {
      logout().then(() => app.ports.logedout.send({}))
    })

    app.ports.login.subscribe(_ => {
      loginWithRedirect()
    })

    app.ports.subscribeEntries.subscribe(_ => {
      console.log('subscribe')
      const queryBuilder = query('entries').where({userId: getCurrentUserId()}).orderByDesc('at');
      const subscription = new DataSubscription(queryBuilder.query);
      subscription.createOnServer();
      subscription.subscribe(entries => {
        console.log('entries', entries)
        app.ports.retrieveEntries.send(entries)
      })
    })
  })
}

main()
