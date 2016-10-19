from django.conf.urls import url
from . import views 

urlpatterns = [
	url(r'^projects/$', views.projects_page, name = 'projects_page'),
	url(r'^projects/PenTool/$', views.pen_tool_page, name = "pen_tool_page"),
]