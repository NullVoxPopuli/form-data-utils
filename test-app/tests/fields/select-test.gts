import { on } from '@ember/modifier';
import { click, render, select as choose } from '@ember/test-helpers';
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
      assert.deepEqual(data, { drone: null });

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

  test('works with single selection (using setValue)', async function (assert) {
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
          <select name="user">
            <option value=""></option>
            {{#each users as |user|}}
              <option value={{user.id}} {{setValue user}}>{{user.name}}</option>
            {{/each}}
          </select>
          <button type="submit">Submit</button>
        </form>
      </template>
    );

    await click('button');
    assert.deepEqual(data, { user: null });

    await choose('[name=user]', '2');
    await click('button');
    assert.deepEqual(data, { user: users[1] });

    await choose('[name=user]', '3');
    await click('button');
    assert.deepEqual(data, { user: users[2] });
  });

  test('works with multiple selection (using setValue)', async function (assert) {
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
          <select name="users" multiple>
            <option value=""></option>
            {{#each users as |user|}}
              <option value={{user.id}} {{setValue user}}>{{user.name}}</option>
            {{/each}}
          </select>
          <button type="submit">Submit</button>
        </form>
      </template>
    );

    await click('button');
    assert.deepEqual(data, { users: [] });

    await choose('[name=users]', '2');
    await click('button');
    assert.deepEqual(data, { users: [users[1]] });

    await choose('[name=users]', ['2', '3']);
    await click('button');
    assert.deepEqual(data, { users: [users[1], users[2]] });
  });
});
