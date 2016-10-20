from django.conf.urls import url
from . import views 

urlpatterns = [
	url(r'^projects/$', views.projects_page, name = 'projects_page'),
	url(r'^projects/PenTool/$', views.pen_tool_page, name = "pen_tool_page"),
	url(r'^projects/Pi/$', views.pi_page, name = "pi_page"),
	url(r'^projects/CompleteTrees/$', views.comp_tree_page, name = "comp_tree_page"),
]