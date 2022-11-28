fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios run_unit_tests

```sh
[bundle exec] fastlane ios run_unit_tests
```

Run all unit tests

### ios run_ui_tests

```sh
[bundle exec] fastlane ios run_ui_tests
```

Run all UI tests

### ios fetch_development_code_signing

```sh
[bundle exec] fastlane ios fetch_development_code_signing
```

Read and install development code signing certificates and provisioning profiles

### ios fetch_production_code_signing

```sh
[bundle exec] fastlane ios fetch_production_code_signing
```

Read and install production code signing certificates and provisioning profiles

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Distribute Testflight build

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
