import { Elm } from './Main.elm';
import {
  initAuth,
  initThinBackend,
  getCurrentUser,
  getCurrentUserId,
  loginWithRedirect,
  logout,
  DataSubscription,
  query,
  createRecord,
  deleteRecord
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

    app.ports.createEntry.subscribe(message => {
      createRecord('entries', {userId: getCurrentUserId(), message})
        .then(() => app.ports.createEntrySuccess.send(null))
        .catch(() => app.ports.createEntryFail.send(null))
    })

    app.ports.deleteEntry.subscribe(id => {
      deleteRecord('entries', id)
        .then(() => app.ports.deleteEntrySuccess.send(null))
        .catch(() => app.ports.deleteEntryFail.send(null))
    })
  })
}

main()
