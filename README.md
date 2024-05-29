# form-data-utils

[Demo](https://ember-primitives.pages.dev/6-utils/data-from-event.md)


A utility function for extracting the FormData as an object from the native `<form>` 
element, allowing more ergonomic of usage of _The Platform_'s default form/fields usage.

Each input within your `<form>` should have a `name` attribute.
(or else the `<form>` element doesn't know what inputs are relevant)

This will provide values for all types of controls/fields,
- input: text, checkbox, radio, etc
- select
  - behavior is fixed from browser default behavior, where
    only the most recently selected value comes through in
    the FormData. This fix only affects `<select multiple>`

## Installation

```
npm add form-data-utils
```

## Usage

```gjs
import { dataFromEvent } from 'form-data-utils';

function handleSubmit(event) {
  event.preventDefault();

  let obj = dataFromEvent(event);
  //  ^ { firstName: NVP, isHuman: "", }
}

<template>
  <form onsubmit={{handleSubmit}}>
    <label>
      First Name
      <input type="text" name="firstName" value="NVP" />
    </label>
    <label> 
      Are you a human?
      <input type="checkbox" name="isHuman" value="nah" />
    </label>
  </form>
</template>
```

## Contributing

See the [Contributing](CONTRIBUTING.md) guide for details.

## License

This project is licensed under the [MIT License](LICENSE.md).
