import { on } from '@ember/modifier';
import { click, render, select as choose } from '@ember/test-helpers';
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';

import { dataFrom } from 'form-data-utils';

module('dataFrom()', function (hooks) {
  setupRenderingTest(hooks);

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
