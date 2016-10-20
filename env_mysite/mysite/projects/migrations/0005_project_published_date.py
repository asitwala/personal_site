# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('projects', '0004_project_nickname'),
    ]

    operations = [
        migrations.AddField(
            model_name='project',
            name='published_date',
            field=models.DateTimeField(null=True, blank=True),
        ),
    ]
