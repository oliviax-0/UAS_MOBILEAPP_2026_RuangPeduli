import django.db.models.deletion
import django.utils.timezone
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('profiles', '0008_societyprofile_profile_picture'),
    ]

    operations = [
        migrations.CreateModel(
            name='KebutuhanItem',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('nama', models.CharField(max_length=200)),
                ('satuan', models.CharField(max_length=50)),
                ('jumlah', models.PositiveIntegerField()),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('panti', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='kebutuhan', to='profiles.orphanageprofile')),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
    ]
