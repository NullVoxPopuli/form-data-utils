type FormDataEntryValue = NonNullable<ReturnType<FormData['get']>>;
type Data = { [key: string]: FormDataEntryValue | string[] };

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
  event: { currentTarget: EventTarget | null },
): {
  [name: string]: FormDataEntryValue | string[];
} {
  if (!event) {
    throw new Error(`Cannot call dataFrom with no event`);
  }

  if (!(event.currentTarget instanceof HTMLFormElement)) {
    throw new Error(
      `Cannot pass dataFrom an object where the currentTarget property's value is not a form`,
    );
  }

  const form = event.currentTarget;
  const formData = new FormData(form);
  const data: Data = Object.fromEntries(formData.entries());

  // Gather fields from the form, and set any missing
  // values to undefined.
  const fields = form.querySelectorAll('input,select');

  for (const field of fields) {
    const name = field.getAttribute('name');

    // The field is probably invalid
    if (!name) continue;

    const hasSubmitted = name in data;

    if (!hasSubmitted) data[name] = '';

    // If the field is a `select`, we need to better
    // handle the value, since only the most recently
    // clicked will beb available
    if (field instanceof HTMLSelectElement) {
      handleSelect(field, data);
    }
  }

  return data;
}

function handleSelect(field: HTMLSelectElement, data: Data) {
  if (field.hasAttribute('multiple')) {
    const options = field.querySelectorAll('option');
    const values = [];

    for (const option of options) {
      if (option.selected) {
        values.push(option.value);
      }
    }

    data[field.name] = values;
  }
}
