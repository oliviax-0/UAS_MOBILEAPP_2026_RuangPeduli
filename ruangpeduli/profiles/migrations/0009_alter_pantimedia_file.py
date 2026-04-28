from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('profiles', '0008_societyprofile_profile_picture'),
    ]

    operations = [
        migrations.AlterField(
            model_name='pantimedia',
            name='file',
            field=models.FileField(blank=True, null=True, upload_to='panti/media/'),
        ),
    ]
