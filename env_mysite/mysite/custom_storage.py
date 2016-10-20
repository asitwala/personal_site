
# reference: https://www.caktusgroup.com/blog/2014/11/10/Using-Amazon-S3-to-store-your-Django-sites-static-and-media-files/

from django.conf import settings 
from storages.backends.s3boto import S3BotoStorage

class StaticStorage(S3BotoStorage):
	location = settings.STATICFILES_LOCATION

class MediaStorage(S3BotoStorage):
	location = settings.MEDIAFILES_LOCATION

