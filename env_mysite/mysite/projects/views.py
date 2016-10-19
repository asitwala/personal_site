from django.shortcuts import render
from .models import Project, ProjectImage

def projects_page(request): 
	projects = Project.objects.all()
	project_images = ProjectImage.objects.all()
	return render(request, 'projects/projects.html', 
		{'projects': projects, 'project_images': project_images})

def pen_tool_page(request): 
	return render(request, 'projects/PenTool.html', {})