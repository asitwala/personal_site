from django.contrib import admin
from .models import * 

# reference: http://stackoverflow.com/questions/9444762/django-admin-multiple-photo-upload

class LinkAdmin(admin.ModelAdmin): 
	pass 

class LinkInline(admin.StackedInline): 
	model = Link
	max_num = 20
	extra = 0

class LinkPostAdmin(admin.ModelAdmin): 
	inlines = [LinkInline,]

admin.site.register(Link, LinkAdmin)
admin.site.register(LinkPost, LinkPostAdmin)
