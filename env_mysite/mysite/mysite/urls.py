"""mysite URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.10/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf.urls import include, url
from django.contrib import admin
from mysite.views import hello


admin.autodiscover()

urlpatterns = [
	url(r'', include('static_pages.urls')),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^hello/$', hello),
    url(r'', include('blog.urls')),
]

# 'r' character in front of the regular expression string
# this tells Python that the string is a "raw string" -- its contents
# should not interpret backslashes 

# (^) : require that the pattern matches the start of the string 
# ($) : require that the pattern matches the end of the string 

# other thing to note about this URLconf is that we've passed the 
# "hello" view function as an object without calling the function 

# this is a key feature of Python (and other dynamic languages)
# functions are first-class objects, which means you can pass them 
# around just like any other variables 

