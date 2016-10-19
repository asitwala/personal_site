from django.db import models
from django.utils import timezone

# we define all objects called Models

class Project(models.Model): 
	author = models.ForeignKey('auth.User')
	image_at_top = models.BooleanField()
	title = models.CharField(max_length = 200)
	organization = models.CharField(max_length = 200)
	team = models.CharField(max_length = 200)
	text = models.TextField()
	link = models.CharField(max_length = 200, default = 'empty')
	nickname = models.CharField(max_length = 100, default = 'empty')

	def publish(self): 
		self.published_date = timezone.now()
		self.save()

	def __str__(self): 
		return self.title 

# define a separate class in order to deal with uploading multiple images 
# reference: http://stackoverflow.com/questions/9444762/django-admin-multiple-photo-upload
class ProjectImage(models.Model): 
	image = models.ImageField(upload_to = 'images/', null = True)
	project = models.ForeignKey(Project)
