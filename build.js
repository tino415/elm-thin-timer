import esbuild from 'esbuild'
import 'dotenv/config'
import ElmPlugin from 'esbuild-plugin-elm';

/* Want to hardcode your app url? Just modify this variable here */
const BACKEND_URL = process.env.BACKEND_URL;
if (!BACKEND_URL) {
  throw new Error('The BACKEND_URL env variable is not set. Open the `.env` file and set the value. You can find the value in your Thin project settings. See https://thin.dev/docs/troubleshooting#BACKEND_URL if you need help.');
}

const isProd = process.env.NODE_ENV === 'production'
const watch = process.argv.includes('--watch')

esbuild
  .build({
    entryPoints: ['./src/index.js'],
    bundle: true,
    outfile: 'public/app.js',
    define: {
      'process.env.NODE_ENV': JSON.stringify("production"),
      'process.env.BACKEND_URL': JSON.stringify(BACKEND_URL)
    },
    plugins: [
      ElmPlugin({
        debug: false,
        optimize: true,
        clearOnWatch: false,
        verbose: false
      }),
    ]
  })
  .catch(() => process.exit(1))
