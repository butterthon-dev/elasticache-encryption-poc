from unittest.mock import patch

from django.test import SimpleTestCase
from django.urls import reverse


class ItemListCreateViewTests(SimpleTestCase):
    @patch('items.views.RedisUtil')
    def test_get_returns_all_items(self, redis_util):
        redis_util.return_value.get_all.return_value = {'foo': 'bar', 'baz': 'qux'}

        response = self.client.get(reverse('items'))

        self.assertEqual(response.status_code, 200)
        self.assertCountEqual(
            response.json(),
            [{'key': 'foo', 'value': 'bar'}, {'key': 'baz', 'value': 'qux'}],
        )

    @patch('items.views.RedisUtil')
    def test_get_returns_empty_list(self, redis_util):
        redis_util.return_value.get_all.return_value = {}

        response = self.client.get(reverse('items'))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), [])

    @patch('items.views.RedisUtil')
    def test_post_sets_key_value(self, redis_util):
        response = self.client.post(
            reverse('items'),
            data={'key': 'foo', 'value': 'bar'},
            content_type='application/json',
        )

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.json(), {'key': 'foo', 'value': 'bar'})
        redis_util.return_value.set.assert_called_once_with('foo', 'bar')

    @patch('items.views.RedisUtil')
    def test_post_rejects_missing_key(self, redis_util):
        response = self.client.post(
            reverse('items'),
            data={'value': 'bar'},
            content_type='application/json',
        )

        self.assertEqual(response.status_code, 400)
        redis_util.return_value.set.assert_not_called()
