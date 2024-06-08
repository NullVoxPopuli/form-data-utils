# form-data-utils

[Demo](https://ember-primitives.pages.dev/6-utils/data-from-event.md)


A utility function for extracting the FormData as an object from the native `<form>` 
element, allowing more ergonomic of usage of _The Platform_'s default form/fields usage.

Each input within your `<form>` should have a `name` attribute.
(or else the `<form>` element doesn't know what inputs are relevant)

This will provide values for all types of controls/fields,
- input: text, checkbox (and checkbox arrays), radio, file, range, etc
- select
  - behavior is fixed from browser default behavior, where
    only the most recently selected value comes through in
    the FormData. This fix only affects `<select multiple>`
- submitter (the button/etc that causes the form to submit (if it has a name attribute))    

## Installation

```
npm add form-data-utils
```

## Usage

```gjs
import { dataFrom } from 'form-data-utils';

function handleSubmit(event) {
  event.preventDefault();

  let obj = dataFrom(event);
  //  ^ { firstName: "NVP", isHuman: null, }
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

    <button type="submit">Submit</button>
  </form>
</template>
```

## Non-primitive values

In some cases, you might want to select values that aren't primitive types, e.g selecting a user from a list of users.
Unfortunately, FormData only supports strings. To work around this, `form-data-utils` provides some utility functions
to "attach" a non-primitive value to an element:

- `setValue(element: HTMLElement, value: unknown)` - binds a given value to a given element (value can be anything, e.g objects, arrays, etc)
- `deleteValue(element: HTMLElement)` - undoes a previous `setValue` call

After setting a value with `setValue`, that value will be considered by the `dataFrom` function.

> [!NOTE]  
> The ideal way to call these functions will probably vary with the framework you're using.

For example, in [Ember.js](https://emberjs.com/), you would use these functions in a modifier that you can then apply to elements.

```gjs
import { dataFrom, deleteValue, setValue } from 'form-data-utils';
import { modifier } from 'ember-modifier';

// define the ember specific modifier
const associateValue = modifier((element, [value]) => {
  setValue(element, value);

  return () => deleteValue(element);
});

function handleSubmit(event) {
  event.preventDefault();

  let obj = dataFrom(event);
  //  ^ { admin: { id: 123, name: 'Sam...' }, user: { id: 321, name: 'Chris...' } }
}

<template>
  <form onsubmit={{handleSubmit}}>
    {{#each users as |user|}}
      <div>
        <input type="radio" name="admin" value={{user.id}} {{associateValue user}} />
        <label for={{user.id}}>{{user.name}}</label>
      </div>
    {{/each}}

    <select name="user">
      <option value=""></option>

      {{#each users as |user|}}
        <option value={{user.id}} {{associateValue user}}>{{user.name}}</option>
      {{/each}}
    </select>

    <button type="submit">Submit</button>
  </form>
</template>
```

`setValue` (and `deleteValue`) doesn't really care how you call it. It just needs an element and a value, that's it.

> [!NOTE]  
> `setValue` only supports `<input type="checkbox"`, `<input type="radio"` and `<select`.

> [!WARNING]  
> The value given by `setValue` has priority. This means that providing both a `value` attribute *and* a value via `setValue` will result in the `value` attribute being ignored by `dataFrom`. However, you might still use the `value` attribute it to create a more meaningful html structure.


## Value types normalization

Another thing that `form-data-utils` does is to normalize the types of the values you get back from `dataFrom`. The following table lists the types you get back depending on the various controls available:

| Control              | Type | Default (empty) value |
| ------------------------- | ------------- | ------------- | 
| `<input type="text"` (email, search, etc)  | `string`         | `''`            |
| `<input type="number"`  | `number`       | `null`             |
| `<input type="range"`    |  `number` |_ranges can't be empty_ |
| `<input type="date"`      | `Date`    | `null`             |
| `<input type="datetime-local"`      | `Date`    | `null`   |
| `<input type="file"`        | [`File`](https://developer.mozilla.org/en-US/docs/Web/API/File)  | `null`             |
| `<input type="file" multiple` | [`File[]`](https://developer.mozilla.org/en-US/docs/Web/API/File)        | `[]`             |
| `<input type="checkbox"` without `value` |  `boolean`        | `false`             |
| `<input type="checkbox"` with `value` |  `GivenValueType`     | `null`             |
| multiple `<input type="checkbox"` with same `name` without `value` |  `boolean[]`        |  `[]`             |
| multiple `<input type="checkbox"` with same `name` with `value` |  `GivenValueType[]`        |  `[]`             |
| `<input type="radio"` | `boolean`        | `false`             |
| `<input type="radio"` with `value` |  `GivenValueType`      | `null`             |
| `<select` |  `GivenValueType`        | `null`             |
| `<select multiple` |  `GivenValueType[]`      | `[]`             |
| `<button type="submit"` with `name` |  `GivenValueType`       | `null`             |


> [!NOTE]  
> `GivenValueType` here means the type of the value you passed in the `value` attribute **or** using the `setValue(element, value)` function.

## Contributing

See the [Contributing](CONTRIBUTING.md) guide for details.

## License

This project is licensed under the [MIT License](LICENSE.md).
