# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('projects', '0005_project_published_date'),
    ]

    operations = [
        migrations.AddField(
            model_name='project',
            name='source_code',
            field=models.TextField(default='empty'),
        ),
    ]
