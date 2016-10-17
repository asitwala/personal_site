
from django.http import HttpResponse
from django.shortcuts import render

# HttpResponse is a class

# hello is a view function 
# each view function takes at least one parameter, called "request" by convention 


# "request" is an object that contains information about the current 
# Web request that has triggered this view 

# and is an instance of the class django.http.HttpRequest
def hello(request): 
	content = "Hello, world!"
	return HttpResponse(content)


# we need to tell Django explicitly that we're activating this view at a particular URL
# hook up a view function to a particular URL 

# a URLconf is like a table of contents for your Django-powered web site