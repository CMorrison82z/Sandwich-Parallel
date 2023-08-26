## Notes

- `before` and `after` jobs have been temporarily removed.

## Examples

See `distributers` for examples of how to implement `Sandwich.Distributer`

## Distributor Implementation Notes

- Roblox modules cannot be required in parallel. Schedules will run a bit slpwer initially as Actors initialize Job modules.