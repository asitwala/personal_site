from django.shortcuts import render
from django.utils import timezone
from .models import Post, PostImage

def post_list(request):
	post_images = PostImage.objects.all()
	posts = Post.objects.filter(published_date__lte = timezone.now()).order_by('published_date')
	return render(request, 'blog/post_list.html', {'posts':posts, 'post_images': post_images})