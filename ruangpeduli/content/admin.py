from django.contrib import admin
from .models import Berita, BeritaImage, BeritaVote, Video

admin.site.register(Berita)
admin.site.register(BeritaImage)
admin.site.register(BeritaVote)
admin.site.register(Video)
