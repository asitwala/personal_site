from django.conf.urls import url
from . import views 

urlpatterns = [
	url(r'^gallery/$', views.gallery_page, name = 'gallery_page'),
	url(r'^gallery/(?P<pk>\d+)/$', views.gallery_detail, name = "gallery_detail"),
]