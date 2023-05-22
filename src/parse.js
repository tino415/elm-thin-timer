import * as Parse from 'parse';

export function init(app) {
  if ("loginPort" in app.ports) {
    app.ports.loginPort.subscribe(_ => {
      console.log('loginWithRedirect requested')
    })
  }

  if ("logoutPort" in app.ports) {
    app.ports.logoutPort.subscribe(_ => {
      // logout().then(() => {
        // if ("logedoutPort" in app.ports) {
          // app.ports.logedoutPort.send({})
        // }
      // })
    })
  }

  if ("listPort" in app.ports) {
    app.ports.listPort.subscribe(q => {
      // const query = translateQuery(q)
      // const results = query.fetchAll()
      // if ("listPortResult" in app.ports) {
        // app.ports.listPortResult.send(results)
      // }
    })
  }

  if ("subscribePort" in app.ports) {
    app.ports.subscribePort.subscribe(q => {
      // const queryBuilder = translateQuery(q)
      // const subscription = new DataSubscription(queryBuilder.query);
      // subscription.createOnServer();
      // subscription.subscribe(items => {
        // if ("subscribeResultPort" in app.ports) {
          // console.log('subscribe items', items)
          // app.ports.subscribeResultPort.send(items)
        // }
      // })
    })
  }

  if ("createRecordPort" in app.ports) {
    app.ports.createRecordPort.subscribe(r => {
      // createRecord(r.collection, r.record)
        // .then(r => {
          // if ("createRecordResultPort" in app.ports) {
            // app.ports.createRecordResultPort.send(r)
          // }
        // })
        // .catch(e => {
          // if ("createRecordResultPort" in app.ports) {
            // app.ports.createRecordResultPort.send(null)
          // }
        // })
    })
  }

  if ("deleteRecordPort" in app.ports) {
    app.ports.deleteRecordPort.subscribe(r => {
      // deleteRecord(r.collection, r.id)
        // .then(_ => {
          // if ("deleteRecordResultPort" in app.ports) {
            // app.ports.deleteRecordResultPort.send(r.id)
          // }
        // })
        // .catch(e => {
          // console.log(e)
          // if ("deleteRecordResultPort" in app.ports) {
            // app.ports.deleteRecordResultPort.send(null)
          // }
        // })
    })
  }
}

function translateQuery(q) {
  // const c = query(q.from)

  // if (q.limit) {
    // c.limit(q.limit)
  // }

  // q.order.forEach(order => {
    // if (order.direction == 'ASC') {
      // c.orderByAsc(order.column)
    // } else {
      // c.orderByDesc(order.column)
    // }
  // })

  // q.andWhere.forEach(equal => {
    // c.where(equal.column, equal.value)
  // })

  // return c
}
