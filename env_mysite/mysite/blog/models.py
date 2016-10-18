from django.db import models
from django.utils import timezone

# we define all objects called Models


class Post(models.Model): 
	author = models.ForeignKey('auth.User')
	title = models.CharField(max_length = 200)
	text = models.TextField()
	created_date = models.DateTimeField(default = timezone.now)
	published_date = models.DateTimeField(blank = True, null = True)


	def publish(self): 
		self.published_date = timezone.now()
		self.save()

	def __str__(self): 
		return self.title 


class PostImage(models.Model): 
	image = models.ImageField(upload_to = 'images/', null = True)
	post = models.ForeignKey(Post)


