import esbuild from 'esbuild'
import { createServer, request } from 'http'
import { spawn } from 'child_process'
import 'dotenv/config'
import ElmPlugin from 'esbuild-plugin-elm';

/* Want to hardcode your app url? Just modify this variable here */
const BACKEND_URL = process.env.BACKEND_URL;
if (!BACKEND_URL) {
  throw new Error('The BACKEND_URL env variable is not set');
}

const APP_ID = process.env.APP_ID
if (!APP_ID) {
  throw new Error('The APP_ID env variable is not set');
}

const JS_KEY = process.env.JS_KEY
if (!JS_KEY) {
  throw new Error('The JS_KEY env variable is not set');
}

const clients = []

const isProd = process.env.NODE_ENV === 'production'
const watch = process.argv.includes('--watch')

esbuild
  .build({
    entryPoints: ['./src/index.js'],
    bundle: true,
    outfile: 'public/app.js',
    banner: { js: ' (() => new EventSource("/esbuild").onmessage = () => location.reload())();' },
    define: {
      'process.env.NODE_ENV': JSON.stringify("development"),
      'process.env.BACKEND_URL': JSON.stringify(BACKEND_URL),
      'process.env.APP_ID': JSON.stringify(APP_ID),
      'process.env.JS_KEY': JSON.stringify(JS_KEY)
    },
    watch: {
      onRebuild(error, result) {
        clients.forEach((res) => res.write('data: update\n\n'))
        clients.length = 0
        console.log(error ? error : '...')
      },
    },
    plugins: [
      ElmPlugin({
        debug: true,
        optimize: isProd,
        clearOnWatch: watch,
        verbose: true,
      }),
    ]
  })
  .catch(() => process.exit(1))

esbuild.serve({ servedir: './public', port: 3001 }, {}).then(() => {
  createServer((req, res) => {
    const { url, method, headers } = req
    if (req.url === '/esbuild')
      return clients.push(
        res.writeHead(200, {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          Connection: 'keep-alive',
        })
      )
    const path = ~url.split('/').pop().indexOf('.') ? url : `/index.html` //for PWA with router
    req.pipe(
      request({ hostname: '0.0.0.0', port: 3001, path, method, headers }, (prxRes) => {
        res.writeHead(prxRes.statusCode, prxRes.headers)
        prxRes.pipe(res, { end: true })
      }),
      { end: true }
    )
  }).listen(3000)

  console.log('Development server running on http://localhost:3000')
})
