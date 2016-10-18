from django.contrib import admin
from .models import *

# reference: http://stackoverflow.com/questions/9444762/django-admin-multiple-photo-upload
class PostImageAdmin(admin.ModelAdmin):
	pass

class PostImageInline(admin.StackedInline): 
	model = PostImage
	max_num = 10
	extra = 0

class PostAdmin(admin.ModelAdmin): 
	inlines = [PostImageInline,]

admin.site.register(PostImage, PostImageAdmin)
admin.site.register(Post, PostAdmin)
