from django.shortcuts import render, get_object_or_404
from django.utils import timezone
from .models import Painting

def gallery_page(request): 
	paintings = Painting.objects.all()[::-1] # place newer objects at top
	return render(request, 'gallery/gallery_page.html', {'paintings': paintings})

# reference: https://tutorial.djangogirls.org/en/extend_your_application/
def gallery_detail(request, pk):
	painting = get_object_or_404(Painting, pk=pk)
	return render(request, 'gallery/gallery_detail.html', {'painting': painting}) 

