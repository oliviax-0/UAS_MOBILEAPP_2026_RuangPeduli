import django.db.models.deletion
import django.utils.timezone
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('inventory', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='StokLaporan',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('amount', models.PositiveIntegerField()),
                ('tipe', models.CharField(choices=[('masuk', 'Masuk'), ('keluar', 'Keluar')], max_length=10)),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('item', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='laporan', to='inventory.inventoryitem')),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
    ]
