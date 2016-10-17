from django.conf.urls import url
from . import views 

urlpatterns = [
	url(r'^links/$', views.links_page, name = 'links_page'),
]