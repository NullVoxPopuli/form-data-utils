import { on } from '@ember/modifier';
import { click, fillIn, render, triggerEvent } from '@ember/test-helpers';
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';

import { modifier } from 'ember-modifier';
import { dataFrom, deleteValue as formDeleteValue,setValue as formSetValue } from 'form-data-utils';

const setValue = modifier((element, [value]) => {
  formSetValue(element, value);

  return () => formDeleteValue(element);
});

module('dataFrom()', function (hooks) {
  setupRenderingTest(hooks);

  module('input', function () {
    test('works with text inputs', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="text" name="firstName" />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { firstName: '' });

      await fillIn('[name=firstName]', 'foo');
      await click('button');
      assert.deepEqual(data, { firstName: 'foo' });
    });

    test('works with number inputs', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="number" name="page" />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { page: null });

      await fillIn('[name=page]', 2);
      await click('button');
      assert.deepEqual(data, { page: 2 });
    });

    test('works with range inputs', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="range" name="page" />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      // range inputs do not support empty (NaN) values like number inputs do
      // not specifying an explicit value will default to value 50
      assert.deepEqual(data, { page: 50 });

      await fillIn('[name=page]', 2);
      await click('button');
      assert.deepEqual(data, { page: 2 });
    });

    test('works with date inputs', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="date" name="when" />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { when: null });

      let now = new Date(Date.UTC(2024, 4, 4));

      await fillIn('[name=when]', "2024-05-04");
      await click('button');
      assert.deepEqual(data, { when: now });
    });

    test('works with datetime-local inputs', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="datetime-local" name="when" />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { when: null });

      let now = new Date(Date.UTC(2024, 4, 4, 12, 13));

      await fillIn('[name=when]', "2024-05-04T12:13");
      await click('button');
      assert.deepEqual(data, { when: now });
    });


    test('works with file inputs (single)', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="file" name="pdf" />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { pdf: null });

      const file = new File(["File contents here"], "file-to-upload.txt");

      await triggerEvent('[name=pdf]', 'change', {
        files: [file],
      });
      await click('button');
      assert.deepEqual(data, { pdf: file });
    });

    test('works with file inputs (multiple)', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="file" name="pdfs" multiple />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { pdfs: [] });

      const file1 = new File(["File contents here"], "file-to-upload.txt");
      const file2 = new File(["File contents here 2"], "file-to-upload-2.txt");

      await triggerEvent('[name=pdfs]', 'change', {
        files: [file1, file2],
      });
      await click('button');
      assert.deepEqual(data, { pdfs: [file1, file2] });
    });

    test('works with checkboxes', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="checkbox" name="isHuman" />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { isHuman: false });

      await click('[name=isHuman]');
      await click('button');
      assert.deepEqual(data, { isHuman: true });

      await click('[name=isHuman]');
      await click('button');
      assert.deepEqual(data, { isHuman: false });
    });

    // this is a bit of a weird use case, but it's supportted nonetheless
    test('works with checkboxes with the same name without value', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="checkbox" name="day" id="checkbox-1" />
            <input type="checkbox" name="day" id="checkbox-2" />
            <input type="checkbox" name="day" id="checkbox-3" />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { day: [] });

      await click('#checkbox-1');
      await click('button');
      assert.deepEqual(data, { day: [true] });

      await click('#checkbox-2');
      await click('button');
      assert.deepEqual(data, { day: [true, true] });
    });

    test('works with checkboxes with the same name with value', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="checkbox" name="day" value="Monday" />
            <input type="checkbox" name="day" value="Tuesday" />
            <input type="checkbox" name="day" value="Wednesday" />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { day: [] });

      await click('[value=Monday]');
      await click('button');
      assert.deepEqual(data, { day: ['Monday'] });

      await click('[value=Tuesday]');
      await click('button');
      assert.deepEqual(data, { day: ['Monday', 'Tuesday'] });
    });

    test('checkboxes can have a custom value', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <input type="checkbox" value="yes" name="isHuman" />
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { isHuman: null });

      await click('[name=isHuman]');
      await click('button');
      assert.deepEqual(data, { isHuman: 'yes' });

      await click('[name=isHuman]');
      await click('button');
      assert.deepEqual(data, { isHuman: null });
    });

    test('works with radios', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            {{! from MDN }}
            <fieldset>
              <legend>Select a maintenance drone:</legend>

              <div>
                <input type="radio" id="huey" name="drone" />
                <label for="huey">Huey</label>
              </div>

              <div>
                <input type="radio" id="dewey" name="drone" value="dewey" />
                <label for="dewey">Dewey</label>
              </div>

              <div>
                <input type="radio" id="louie" name="drone" value="louie" />
                <label for="louie">Louie</label>
              </div>
            </fieldset>
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { drone: null });

      await click('[value=dewey]');
      await click('button');
      assert.deepEqual(data, { drone: 'dewey' });

      await click('[value=louie]');
      await click('button');
      assert.deepEqual(data, { drone: 'louie' });
    });

    test('works with radios (using setValue)', async function (assert) {
      let data = {};

      const users = [
        { id: 1, name: 'Sam' },
        { id: 2, name: 'Chris' },
        { id: 3, name: 'Dan' }
      ];

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <fieldset>
              <legend>Select a maintenance drone:</legend>

              {{#each users as |user|}}
                <div>
                  <input type="radio" id="user-{{user.id}}" name="user" {{setValue user}} />
                  <label for={{user.id}}>{{user.name}}</label>
                </div>
              {{/each}}
            </fieldset>
            <button type="submit">Submit</button>
          </form>
        </template>
      );
      await click('button');
      assert.deepEqual(data, { user: null });

      await click('#user-2');
      await click('button');
      assert.deepEqual(data, { user: users[1] });

      await click('#user-3');
      await click('button');
      assert.deepEqual(data, { user: users[2] });
    });
  });

  test('works with checkboxes (using setValue)', async function (assert) {
    let data = {};

    let option = { id: 1, name: 'Sam' };

    function handleSubmit(event: SubmitEvent) {
      event.preventDefault();
      data = dataFrom(event);
    }

    await render(
      <template>
        <form {{on "submit" handleSubmit}}>
          <input type="checkbox" name="isHuman" {{setValue option}}/>
          <button type="submit">Submit</button>
        </form>
      </template>
    );

    await click('button');
    assert.deepEqual(data, { isHuman: null });

    await click('[name=isHuman]');
    await click('button');
    assert.deepEqual(data, { isHuman: option });

    await click('[name=isHuman]');
    await click('button');
    assert.deepEqual(data, { isHuman: null });
  });

  test('works with checkboxes with the same name (using setValue)', async function (assert) {
    let data = {};

    const users = [
      { id: 1, name: 'Sam' },
      { id: 2, name: 'Chris' },
      { id: 3, name: 'Dan' }
    ];

    function handleSubmit(event: SubmitEvent) {
      event.preventDefault();
      data = dataFrom(event);
    }

    await render(
      <template>
        <form {{on "submit" handleSubmit}}>
          {{#each users as |user|}}
            <input type="checkbox" name="day" id="user-{{user.id}}" {{setValue user}} />
          {{/each}}
          <button type="submit">Submit</button>
        </form>
      </template>
    );

    await click('button');
    assert.deepEqual(data, { day: [] });

    await click('#user-2');
    await click('button');
    assert.deepEqual(data, { day: [users[1]] });

    await click('#user-3');
    await click('button');
    assert.deepEqual(data, { day: [users[1], users[2]] });
  });
});
