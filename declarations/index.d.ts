declare type Data = {
    [key: string]: FormDataEntryValue_2[] | FormDataEntryValue_2 | string[] | number | Date | File | File[] | unknown | unknown[] | null;
};

/**
 * A utility function for extracting the FormData as an object
 */
export declare function dataFrom(
/**
 * The submit event from the event listener on the form.
 * The currentTarget must be a `<form>`
 *
 *
 * Each input within your `<form>` should have a `name` attribute.
 * (or else the `<form>` element doesn't know what inputs are relevant)
 */
event: {
    currentTarget: EventTarget | null;
    submitter?: HTMLElement | null | undefined;
}): Data;

export declare function deleteValue(element: HTMLElement): boolean;

declare type FormDataEntryValue_2 = NonNullable<ReturnType<FormData['get']>>;

export declare function setValue(element: HTMLElement, value: unknown): void;

export { }
