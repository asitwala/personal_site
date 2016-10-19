# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models
from django.conf import settings


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Project',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False, auto_created=True, verbose_name='ID')),
                ('image_at_top', models.BooleanField()),
                ('title', models.CharField(max_length=200)),
                ('organization', models.CharField(max_length=200)),
                ('team', models.CharField(max_length=200)),
                ('text', models.TextField()),
                ('link', models.SlugField(max_length=200, null=True)),
                ('author', models.ForeignKey(to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='ProjectImage',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False, auto_created=True, verbose_name='ID')),
                ('image', models.ImageField(upload_to='images/', null=True)),
                ('project', models.ForeignKey(to='projects.Project')),
            ],
        ),
    ]
