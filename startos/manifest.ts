import { setupManifest } from '@start9labs/start-sdk'

export const manifest = setupManifest({
  id: 'btctx',
  title: 'BitcoinTX',
  license: 'MIT',
  wrapperRepo: 'https://github.com/PlebRick/BTCTX-StartOS',
  upstreamRepo: 'https://github.com/PlebRick/BTCTX',
  supportSite: 'https://github.com/PlebRick/BTCTX',
  marketingSite: 'https://github.com/PlebRick/BTCTX',
  donationUrl: 'https://github.com/PlebRick/BTCTX',
  description: {
    short: 'A Bitcoin transaction and accounting service',
    long: 'BitcoinTX (BTCTX) is a Vite/React and FastAPI project for managing and analyzing Bitcoin transactions.',
  },
  // If you have additional static assets, add them here, e.g. images/binaries
  assets: [],
  // If your service needs persistent data (like a DB), you can keep "main" here
  // or define multiple volumes if needed. If truly stateless, you can omit.
  volumes: ['main'],
  store: {
    main: {
      path: '/data', // This is where the SQLite database file will be stored
    },
  },

  // Images is where we define the Docker image(s) for this package
  images: {
    main: {
      source: {
        dockerBuild: {
          dockerfile: './Dockerfile',
          workdir: '.',
        },
      },
      arch: ['x86_64', 'aarch64'],  // Ensures it builds for both architectures
      emulateMissingAs: 'aarch64',  // Needed for cross-platform builds
    },
  },

  hardwareRequirements: {},

  // Alerts can be displayed at different lifecycle events
  alerts: {
    install: null, // or 'Optional alert before installing'
    update: null,
    uninstall: null,
    restore: null,
    start: null,
    stop: null,
  },

  // Declare dependencies on other services if needed, e.g. "bitcoind"
  dependencies: {},
})
