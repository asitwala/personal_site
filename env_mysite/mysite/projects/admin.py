from django.contrib import admin
from .models import *

# reference: http://stackoverflow.com/questions/9444762/django-admin-multiple-photo-upload
class ProjectImageAdmin(admin.ModelAdmin):
	pass

class ProjectImageInline(admin.StackedInline): 
	model = ProjectImage
	max_num = 10
	extra = 0

class ProjectAdmin(admin.ModelAdmin): 
	inlines = [ProjectImageInline,]

admin.site.register(ProjectImage, ProjectImageAdmin)
admin.site.register(Project, ProjectAdmin)

