# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('projects', '0003_project_link'),
    ]

    operations = [
        migrations.AddField(
            model_name='project',
            name='nickname',
            field=models.CharField(max_length=100, default='empty'),
        ),
    ]
