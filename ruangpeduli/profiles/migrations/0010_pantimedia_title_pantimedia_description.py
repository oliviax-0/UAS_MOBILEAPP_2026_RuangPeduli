from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('profiles', '0009_alter_pantimedia_file'),
    ]

    operations = [
        migrations.AddField(
            model_name='pantimedia',
            name='title',
            field=models.CharField(max_length=200, blank=True, default=''),
        ),
        migrations.AddField(
            model_name='pantimedia',
            name='description',
            field=models.TextField(blank=True, default=''),
        ),
    ]
