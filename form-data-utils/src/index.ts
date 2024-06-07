type FormDataEntryValue = NonNullable<ReturnType<FormData['get']>>;
type Data = { [key: string]: FormDataEntryValue[] | FormDataEntryValue | string[] | number | Date | File | File[] | null };

/**
 * A utility function for extracting the FormData as an object
 */
export function dataFrom(
  /**
   * The submit event from the event listener on the form.
   * The currentTarget must be a `<form>`
   *
   *
   * Each input within your `<form>` should have a `name` attribute.
   * (or else the `<form>` element doesn't know what inputs are relevant)
   */
  event: {
    currentTarget: EventTarget | null,
    submitter?: HTMLElement | null | undefined
  },
): Data {
  if (!event) {
    throw new Error(`Cannot call dataFrom with no event`);
  }

  if (!(event.currentTarget instanceof HTMLFormElement)) {
    throw new Error(
      `Cannot pass dataFrom an object where the currentTarget property's value is not a form`,
    );
  }

  const form = event.currentTarget;
  const formData = new FormData(form, event.submitter);
  const data: Data = Object.fromEntries(formData.entries());

  for (const field of form.elements) {
    const name = field.getAttribute('name');

    // The field is probably invalid
    if (!name) continue;

    const hasSubmitted = name in data;

    // Default to empty string, because
    // by default FormData does not include fields
    // that were not checked
    if (!hasSubmitted) data[name] = '';

    // If the field is a `select`, we need to better
    // handle the value, since only the most recently
    // clicked will be available
    if (field instanceof HTMLSelectElement) {
      if (field.hasAttribute('multiple')) {
        data[field.name] = formData.getAll(field.name);
      }
    } else if (field instanceof HTMLInputElement) {
      const _related = form.querySelectorAll(`[name="${name}"]`)
      const related = [..._related] as unknown[] as HTMLInputElement[];

      if (!(related.every(x => x instanceof HTMLInputElement))) {
        throw new Error(`Every element with name ${name} must be an input`);
      }

      const hasMultipleValues = related.length > 1;

      /**
        * By default, all input values are strings.
        * But with type=number, we can use a different API to get the
        * actual numerical value.
        */
      switch (field.type) {
        case 'number':
        case 'range': {
          data[field.name] = field.valueAsNumber;

          break;
        }
        case 'date': {
          data[field.name] = field.valueAsDate;

          break;
        }
        case 'datetime-local': {
          // datetime-local inputs do not have a `valueAsDate`, but they do have a `valueAsNumber`
          // which is the number of milliseconds since January 1, 1970, UTC
          // - to mimic input[type="date"], we return null when input is not filled (`valueAsNumber` is NaN)
          // - when `valueAsNumber` is a number, we create a new date with its value
          data[field.name] = isNaN(field.valueAsNumber) ? null : new Date(field.valueAsNumber);

          break;
        }
        case 'checkbox': {
          // TODO: do multiple field types need to support arrays like this?
          if (hasMultipleValues) {
            data[field.name] = related.filter(x => x.checked).map(x => x.value);
          }

          break;
        }
        case 'file': {
          if (field.files && field.files.length > 0) {
            data[field.name] = field.multiple ? Array.from(field.files) : field.files[0] || null;
          } else {
            data[field.name] = field.multiple ? [] : null;
          }

          break;
        }
      }
    }
  }

  return data;
}

