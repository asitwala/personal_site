from django.shortcuts import render

def homepage(request):
	return render(request, 'static_pages/homepage.html', {})

def about(request): 
	return render(request, 'static_pages/about.html', {})
