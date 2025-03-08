import { sdk } from '../sdk'
import { yamlFile } from '../file-models/config.yml'

const { InputSpec, Value } = sdk

export const inputSpec = InputSpec.of({
  name: Value.text({
    name: 'Name',
    description:
      'When you launch the BitcoinTX UI, it will display "Welcome, [Name]"',
    required: true,
    default: 'User',
  }),
})

export const setName = sdk.Action.withInput(
  // id
  'set-name',

  // metadata
  async ({ effects }) => ({
    name: 'Set Name',
    description: 'Set your display name for BitcoinTX',
    warning: null,
    allowedStatuses: 'any',
    group: null,
    visibility: 'enabled',
  }),

  // form input specification
  inputSpec,

  // optionally pre-fill the input form
  async ({ effects }) => yamlFile.read.const(effects),

  // the execution function
  async ({ effects, input }) => {
    const yaml = await yamlFile.read.const(effects)

    if (yaml?.name === input.name) return

    await Promise.all([
      yamlFile.merge(input),
      sdk.store.setOwn(
        effects,
        sdk.StorePath.nameLastUpdatedAt, // ✅ FIXED: Use this instead of `from`
        new Date().toISOString(),
      ),
    ])
  },
)
