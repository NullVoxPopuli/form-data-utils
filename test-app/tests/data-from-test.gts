import { on } from '@ember/modifier';
import { click, fillIn, render, select as choose } from '@ember/test-helpers';
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';

import { dataFrom } from 'form-data-utils';

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
      assert.deepEqual(data, { page: NaN });

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
      assert.deepEqual(data, { isHuman: '' });

      await click('[name=isHuman]');
      await click('button');
      assert.deepEqual(data, { isHuman: 'on' });

      await click('[name=isHuman]');
      await click('button');
      assert.deepEqual(data, { isHuman: '' });
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
      assert.deepEqual(data, { isHuman: '' });

      await click('[name=isHuman]');
      await click('button');
      assert.deepEqual(data, { isHuman: 'yes' });

      await click('[name=isHuman]');
      await click('button');
      assert.deepEqual(data, { isHuman: '' });
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
                <input type="radio" id="huey" name="drone" value="huey" checked />
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
      assert.deepEqual(data, { drone: 'huey' });

      await click('[value=dewey]');
      await click('button');
      assert.deepEqual(data, { drone: 'dewey' });

      await click('[value=louie]');
      await click('button');
      assert.deepEqual(data, { drone: 'louie' });
    });
  });

  module('select', function () {
    test('works with single selection', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <select name="drone">
              <option value=""></option>
              <option value="huey">Huey</option>
              <option value="dewey">Dewey</option>
              <option value="louie">Louie</option>
            </select>
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { drone: '' });

      await choose('[name=drone]', 'huey');
      await click('button');
      assert.deepEqual(data, { drone: 'huey' });

      await choose('[name=drone]', 'dewey');
      await click('button');
      assert.deepEqual(data, { drone: 'dewey' });
    });

    test('works with multiple selection', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <select multiple name="drone">
              <option value=""></option>
              <option value="huey">Huey</option>
              <option value="dewey">Dewey</option>
              <option value="louie">Louie</option>
            </select>
            <button type="submit">Submit</button>
          </form>
        </template>
      );

      await click('button');
      assert.deepEqual(data, { drone: [] });

      await choose('[name=drone]', 'huey');
      await click('button');
      assert.deepEqual(data, { drone: ['huey'] });

      await choose('[name=drone]', 'dewey');
      await click('button');
      assert.deepEqual(data, { drone: ['dewey'] });

      await choose('[name=drone]', ['huey', 'dewey']);
      await click('button');
      assert.deepEqual(data, { drone: ['huey', 'dewey'] });
    });
  });
});
