from django.db import models
from accounts.models import User


class Berita(models.Model):
    title = models.CharField(max_length=255)
    content = models.TextField()
    thumbnail = models.ImageField(upload_to='berita/thumbnails/', blank=True, null=True)
    author = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='beritas')
    panti = models.ForeignKey(
        'profiles.OrphanageProfile',
        on_delete=models.CASCADE,
        related_name='beritas'
    )
    is_published = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

    @property
    def upvote_count(self):
        return self.votes.filter(vote_type='up').count()

    @property
    def downvote_count(self):
        return self.votes.filter(vote_type='down').count()

    class Meta:
        ordering = ['-created_at']
        verbose_name_plural = "Beritas"


class BeritaImage(models.Model):
    berita = models.ForeignKey(Berita, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='berita/images/')
    caption = models.CharField(max_length=255, blank=True)
    order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"Image for {self.berita.title} ({self.order})"


class BeritaVote(models.Model):
    VOTE_CHOICES = [('up', 'Up'), ('down', 'Down')]

    berita = models.ForeignKey(Berita, on_delete=models.CASCADE, related_name='votes')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='votes')
    vote_type = models.CharField(max_length=4, choices=VOTE_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('berita', 'user')

    def __str__(self):
        return f"{self.user.username} → {self.vote_type} on {self.berita.title}"


class Video(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    video_url = models.URLField()
    thumbnail = models.ImageField(upload_to='videos/thumbnails/', blank=True, null=True)
    author = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='videos')
    panti = models.ForeignKey(
        'profiles.OrphanageProfile',
        on_delete=models.CASCADE,
        related_name='videos'
    )
    is_published = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

    class Meta:
        ordering = ['-created_at']
        verbose_name_plural = "Videos"
