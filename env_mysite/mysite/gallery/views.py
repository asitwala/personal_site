from django.shortcuts import render
from django.utils import timezone
from .models import Painting

def gallery_page(request): 
	paintings = Painting.objects.filter(published_date__lte = timezone.now()).order_by('published_date')
	return render(request, 'gallery/gallery_page.html', {'paintings': paintings})
