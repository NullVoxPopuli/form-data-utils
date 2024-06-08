type FormDataEntryValue = NonNullable<ReturnType<FormData['get']>>;
type Data = { [key: string]: FormDataEntryValue[] | FormDataEntryValue | string[] | number | Date | File | File[] | unknown | unknown[] | null };

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

    // Default to null, because by default FormData does not include fields
    // that were not checked. We exclude buttons, because their value should only
    // be added if they're pressed.
    if (!hasSubmitted && !(field instanceof HTMLButtonElement)) data[name] = null;

    // If the field is a `select`, we need to better
    // handle the value, since only the most recently
    // clicked will be available
    if (field instanceof HTMLSelectElement) {
      data[field.name] = getSelectValue(field);
    } else if (field instanceof HTMLButtonElement && hasSubmitted) {
      // normalize empty valued buttons to null. Only consider buttons that were submitted (default forms behavior)
      data[field.name] = field.value || null;
    } else if (field instanceof HTMLInputElement) {
      const _related = form.querySelectorAll(`[name="${name}"]`)
      const related = Array.from(_related) as HTMLInputElement[];

      if (!(related.every(x => x instanceof HTMLInputElement))) {
        throw new Error(`Every element with name ${name} must be an input`);
      }

      const hasMultipleValues = related.length > 1;

      /**
        * By default, all input values are strings.
        * So we need to normalize the types returned to the user.
        */
      switch (field.type) {
        case 'number':
        case 'range': {
          data[field.name] = isNaN(field.valueAsNumber) ? null : field.valueAsNumber;

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
          if (hasMultipleValues) {
            data[field.name] = related.filter(x => x.checked).map(x => getRadioCheckboxValue(x));
          } else {
            data[field.name] = getRadioCheckboxValue(field);
          }

          break;
        }
        case 'radio': {
          let radio: HTMLInputElement | undefined;

          if (hasMultipleValues) {
            radio = related.find(x => x.checked);
          } else {
            radio = field;
          }

          data[field.name] = radio ? getRadioCheckboxValue(radio) : null;

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

function getSelectValue(field: HTMLSelectElement) {
  return field.multiple ? getMultipleSelectValue(field) : getSingleSelectValue(field);
}

function getSingleSelectValue(field: HTMLSelectElement) {
  // avoid looping if we know nothing is selected
  if (field.selectedIndex === -1) return null;

  let optionValue: unknown = null;

  for (let opt of field.options) {
    if (!opt.disabled && opt.selected) {
      optionValue = getOptionValue(opt);
    }
  }

  return optionValue;
}

function getMultipleSelectValue(field: HTMLSelectElement) {
  // avoid looping if we know nothing is selected
  if (field.selectedIndex === -1) return [];

  let optionValues: unknown[] = [];

  for (let opt of field.options) {
    if (!opt.disabled && opt.selected && opt.value !== '') {
      optionValues.push(getOptionValue(opt));
    }
  }

  return optionValues;
}

function getOptionValue(opt: HTMLOptionElement) {
  if (!opt.disabled && opt.selected) {
    // we normalize empty string to null
    if (opt.value === '') return null;

    return getValue(opt) || opt.value;
  }
}

function getRadioCheckboxValue(el: HTMLInputElement) {
  if (el.disabled) return;

  // if radio or checkbox were not supplied any value, we assume the user wants a boolean
  // el.getAttribute('value') returns null when value is not supplied (el.value returns 'on', so we can't use it)
  const isValueDefined = el.getAttribute('value') !== null || getValue(el);

  if (!el.disabled) {
    if (!isValueDefined) return getValue(el) || el.checked;

    if (el.checked) {
      return getValue(el) || el.value;
    } else {
      return null;
    }
  }
}

// utils to allow setting non-primitive values

const values: WeakMap<Element, unknown> = new WeakMap();

export function setValue(element: HTMLElement, value: unknown) {
  values.set(element, value);
}

export function deleteValue(element: HTMLElement) {
  return values.delete(element);
}

function getValue(element: HTMLElement) {
  return values.get(element);
}
