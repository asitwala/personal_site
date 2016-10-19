from django.shortcuts import render

def projects_page(request): 
	return render(request, 'projects/projects.html', {})

def pen_tool_page(request): 
	return render(request, 'projects/PenTool.html', {})