from __future__ import unicode_literals
from django.db import models
from django.utils import timezone


class Painting (models.Model): 
	
	author = models.ForeignKey('auth.User')
	image = models.ImageField(upload_to = 'images/')
	title = models.CharField(max_length = 200)
	text = models.TextField()
	created_date = models.DateTimeField(default = timezone.now)
	published_date = models.DateTimeField(blank = True, null = True)


	def publish(self): 
		self.published_date = timezone.now()
		self.save()

	def __str__(self): 
		return self.title 
