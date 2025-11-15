# Context Manifest

Each Context ships with a manifest file:

context.yaml
```yaml
name: Fold
version: 0.1
api-version: 1.0
author: Chad Thomas
dependencies: []
entry: fold.init
permissions:
  - physics.extend
  - ecs.components.add
  - scripting.capabilities.add
```
Defines:
  - name/version
  - engine API version
  - dependencies
  - initial entry point
  - required permissions
