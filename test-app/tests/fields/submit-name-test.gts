import { on } from '@ember/modifier';
import { click, render } from '@ember/test-helpers';
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';

import { dataFrom } from 'form-data-utils';

module('dataFrom()', function (hooks) {
  setupRenderingTest(hooks);

  module('button', function () {
    test('submits name and value', async function (assert) {
      let data = {};

      function handleSubmit(event: SubmitEvent) {
        event.preventDefault();
        data = dataFrom(event);
      }

      await render(
        <template>
          <form {{on "submit" handleSubmit}}>
            <button type="submit" name="one">Submit</button>
            <button type="submit" name="two" value="second">Submit 2</button>
          </form>
        </template>
      );

      await click('button[name=one]');
      assert.deepEqual(data, { one: '', two: '' });

      await click('button[name=two]');
      assert.deepEqual(data, { one: '', two: 'second' });
    });
  });
});
