from __future__ import unicode_literals
from django.db import models
from django.utils import timezone

# Create your models here.

class LinkPost(models.Model): 

	author = models.ForeignKey('auth.User')
	title = models.CharField(max_length = 200)
	published_date = models.DateTimeField(blank = True, null = True)

	def publish(self): 
		self.published_date = timezone.now()
		self.save()

	def __str__(self): 
		return self.title 

class Link(models.Model): 
	linkdesc = models.TextField(default = "")
	linksite = models.TextField()
	linkpost = models.ForeignKey(LinkPost)

