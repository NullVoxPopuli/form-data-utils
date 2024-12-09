function dataFrom(event) {
  if (!event) {
    throw new Error(`Cannot call dataFrom with no event`);
  }
  if (!(event.currentTarget instanceof HTMLFormElement)) {
    throw new Error(
      `Cannot pass dataFrom an object where the currentTarget property's value is not a form`
    );
  }
  const form = event.currentTarget;
  const formData = new FormData(form, event.submitter);
  const data = Object.fromEntries(formData.entries());
  for (const field of form.elements) {
    const name = field.getAttribute("name");
    if (!name) continue;
    const hasSubmitted = name in data;
    if (!hasSubmitted && !(field instanceof HTMLButtonElement)) data[name] = null;
    if (field instanceof HTMLSelectElement) {
      data[field.name] = getSelectValue(field);
    } else if (field instanceof HTMLButtonElement && hasSubmitted) {
      data[field.name] = field.value || null;
    } else if (field instanceof HTMLInputElement) {
      const _related = form.querySelectorAll(`[name="${name}"]`);
      const related = Array.from(_related);
      if (!related.every((x) => x instanceof HTMLInputElement)) {
        throw new Error(`Every element with name ${name} must be an input`);
      }
      const hasMultipleValues = related.length > 1;
      switch (field.type) {
        case "number":
        case "range": {
          data[field.name] = isNaN(field.valueAsNumber) ? null : field.valueAsNumber;
          break;
        }
        case "date": {
          data[field.name] = field.valueAsDate;
          break;
        }
        case "datetime-local": {
          data[field.name] = isNaN(field.valueAsNumber) ? null : new Date(field.valueAsNumber);
          break;
        }
        case "checkbox": {
          if (hasMultipleValues) {
            data[field.name] = related.filter((x) => x.checked).map((x) => getRadioCheckboxValue(x));
          } else {
            data[field.name] = getRadioCheckboxValue(field);
          }
          break;
        }
        case "radio": {
          let radio;
          if (hasMultipleValues) {
            radio = related.find((x) => x.checked);
          } else {
            radio = field;
          }
          data[field.name] = radio ? getRadioCheckboxValue(radio) : null;
          break;
        }
        case "file": {
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
function getSelectValue(field) {
  return field.multiple ? getMultipleSelectValue(field) : getSingleSelectValue(field);
}
function getSingleSelectValue(field) {
  if (field.selectedIndex === -1) return null;
  let optionValue = null;
  for (let opt of field.options) {
    if (!opt.disabled && opt.selected) {
      optionValue = getOptionValue(opt);
    }
  }
  return optionValue;
}
function getMultipleSelectValue(field) {
  if (field.selectedIndex === -1) return [];
  let optionValues = [];
  for (let opt of field.options) {
    if (!opt.disabled && opt.selected && opt.value !== "") {
      optionValues.push(getOptionValue(opt));
    }
  }
  return optionValues;
}
function getOptionValue(opt) {
  if (!opt.disabled && opt.selected) {
    if (opt.value === "") return null;
    return getValue(opt) || opt.value;
  }
}
function getRadioCheckboxValue(el) {
  if (el.disabled) return;
  const isValueDefined = el.getAttribute("value") !== null || getValue(el);
  if (!isValueDefined) return getValue(el) || el.checked;
  if (el.checked) {
    return getValue(el) || el.value;
  }
  return null;
}
const values = /* @__PURE__ */ new WeakMap();
function setValue(element, value) {
  values.set(element, value);
}
function deleteValue(element) {
  return values.delete(element);
}
function getValue(element) {
  return values.get(element);
}
export {
  dataFrom,
  deleteValue,
  setValue
};
//# sourceMappingURL=index.js.map
