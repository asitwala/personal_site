from django.shortcuts import render, get_object_or_404
from .models import LinkPost, Link

def links_page(request): 
	linkposts = LinkPost.objects.all()
	return render(request, 'links/links_page.html', {'linkposts': linkposts})

# reference: https://tutorial.djangogirls.org/en/extend_your_application/
def links_detail(request, pk): 
	linkpost = get_object_or_404(LinkPost, pk=pk)
	links = Link.objects.all()
	return render(request, 'links/links_detail.html', {'linkpost': linkpost,
		'links': links})
