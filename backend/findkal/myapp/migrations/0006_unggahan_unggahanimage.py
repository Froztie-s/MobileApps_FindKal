import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('myapp', '0005_user_bio_user_profile_photo'),
    ]

    operations = [
        migrations.CreateModel(
            name='Unggahan',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('nama_tempat', models.CharField(max_length=200)),
                ('alamat', models.TextField()),
                ('ulasan', models.TextField()),
                ('rating', models.PositiveSmallIntegerField()),
                ('budget', models.CharField(choices=[
                    ('Rp 1k - Rp 50k', 'Rp 1k - Rp 50k'),
                    ('Rp 50k - Rp 100k', 'Rp 50k - Rp 100k'),
                    ('Rp 100k - Rp 150k', 'Rp 100k - Rp 150k'),
                    ('Rp 150k - Rp 200k', 'Rp 150k - Rp 200k'),
                    ('Rp 250k+', 'Rp 250k+'),
                ], max_length=30)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('user', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='unggahans',
                    to=settings.AUTH_USER_MODEL,
                )),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
        migrations.CreateModel(
            name='UnggahanImage',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('image', models.ImageField(upload_to='unggahan_images/')),
                ('order', models.PositiveSmallIntegerField(default=0)),
                ('unggahan', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='images',
                    to='myapp.unggahan',
                )),
            ],
            options={
                'ordering': ['order'],
            },
        ),
    ]
