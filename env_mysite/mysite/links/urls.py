from django.conf.urls import url
from . import views 

urlpatterns = [
	url(r'^links/$', views.links_page, name = 'links_page'),
	url(r'^links/(?P<pk>\d+)/$', views.links_detail, name = 'links_detail'),
]