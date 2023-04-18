import {
  DataSubscription,
  query
} from 'thin-backend';

export function init(app) {
  if ("listPort" in app.ports) {
    app.ports.listPort.subscribe(q => {
      const query = translateQuery(q)
      const results = query.fetchAll()
      if ("listPortResult" in app.ports) {
        app.ports.listPortResult.send(results)
      }
    })
  }

  if ("subscribePort" in app.ports) {
    app.ports.subscribePort.subscribe(q => {
      const queryBuilder = translateQuery(q)
      const subscription = new DataSubscription(queryBuilder.query);
      subscription.createOnServer();
      subscription.subscribe(items => {
        if ("subscribePortResult" in app.ports) {
          app.ports.subscribePortResult.send(items)
        }
      })
    })
  }
}

function translateQuery(q) {
  const c = query(q.from)

  console.log('c', c, 'q', q)

  if (q.limit) {
    c.limit(q.limit)
  }

  q.order.forEach(order => {
    if (order.direction == 'ASC') {
      c.orderByAsc(order.column)
    } else {
      c.orderByDesc(order.column)
    }
  })

  q.andWhere.forEach(equal => {
    c.where(equal.column, equal.value)
  })

  return c
}
