import { sdk } from './sdk'
import { T } from '@start9labs/start-sdk'
import { uiPort } from './utils'

export const main = sdk.setupMain(async ({ effects, started }) => {
  console.info('Starting BitcoinTX')

  // Additional health checks can be appended here
  const healthReceipts: T.HealthReceipt[] = []

  // Create a single daemon named 'primary'
  return sdk.Daemons.of(effects, started, healthReceipts).addDaemon('primary', {
    subcontainer: { imageId: 'main' },
    command: ['sh', '-c', 'python3 backend/create_db.py && uvicorn backend.main:app --host 0.0.0.0 --port 8000'],    
    mounts: sdk.Mounts.of().addVolume('main', null, '/data', false),

    // Define a readiness check to see if port 8000 is listening
    ready: {
      display: 'BTCTX Web Interface',
      fn: () =>
        sdk.healthCheck.checkPortListening(effects, uiPort, {
          successMessage: 'BTCTX web interface is ready',
          errorMessage: 'BTCTX web interface is not responding',
        }),
    },

    // If this daemon depends on other services, list them here
    requires: [],
  })
})