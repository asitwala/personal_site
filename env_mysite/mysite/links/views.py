from django.shortcuts import render

def links_page(request): 
	return render(request, 'links/links_page.html', {})