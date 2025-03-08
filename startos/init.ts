import { sdk } from './sdk'
import { versions } from './versions'
import { setDependencies } from './dependencies'
import { setInterfaces } from './interfaces'
import { actions } from './actions'
import { exposedStore } from './store'

// **** Install ****
const install = sdk.setupInstall(async ({ effects }) => {
  // No special logic for now
  console.info('Installing BTCTX...')
})

// **** Uninstall ****
const uninstall = sdk.setupUninstall(async ({ effects }) => {
  // No special logic for now
  console.info('Uninstalling BTCTX...')
})

/**
 * ============== Plumbing. DO NOT EDIT. ==============
 */
export const { packageInit, packageUninit, containerInit } = sdk.setupInit(
  versions,
  install,
  uninstall,
  setInterfaces,
  setDependencies,
  actions,
  exposedStore,
)
