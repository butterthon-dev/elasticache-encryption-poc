from django.test import SimpleTestCase
from django.urls import reverse


class HealthCheckViewTests(SimpleTestCase):
    def test_returns_ok(self):
        response = self.client.get(reverse('healthz'))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {'status': 'ok'})

    def test_post_not_allowed(self):
        response = self.client.post(reverse('healthz'))

        self.assertEqual(response.status_code, 405)
