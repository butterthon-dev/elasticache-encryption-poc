from django.urls import path

from items.views import ItemListCreateView

urlpatterns = [
    path('items', ItemListCreateView.as_view(), name='items'),
]
