from django.core.management.base import BaseCommand
from accounts.models import User
from profiles.models import OrphanageProfile

PANTI_DATA = [
    {
        'username': 'panti_mekar_lestari',
        'email': 'mekar.lestari@ruangpeduli.id',
        'password': 'panti123',
        'nama_panti': 'Panti Asuhan Mekar Lestari',
        'alamat_panti': 'Jl. Komersial III No.1, Blok B1',
        'nomor_panti': '+622153153088',
        'description': 'Panti asuhan yang berdiri sejak 2005, melayani anak-anak yatim piatu di wilayah Serpong dan sekitarnya.',
        'provinsi': 'Banten',
        'kabupaten_kota': 'Kota Tangerang Selatan',
        'kecamatan': 'Serpong',
        'kelurahan': 'Lengkong Gudang Timur',
        'kode_pos': '15310',
        'lat': -6.278900,
        'lng': 106.661900,
    },
    {
        'username': 'panti_kasih_sesama',
        'email': 'kasih.sesama@ruangpeduli.id',
        'password': 'panti123',
        'nama_panti': 'Panti Asuhan Kasih Sesama',
        'alamat_panti': 'Jl. Benda Raya VI No.12',
        'nomor_panti': '+62217405720',
        'description': 'Panti asuhan yang berfokus pada pendidikan dan pemberdayaan anak-anak kurang mampu di Pamulang.',
        'provinsi': 'Banten',
        'kabupaten_kota': 'Kota Tangerang Selatan',
        'kecamatan': 'Pamulang',
        'kelurahan': 'Pamulang Barat',
        'kode_pos': '15416',
        'lat': -6.338400,
        'lng': 106.732200,
    },
    {
        'username': 'yayasan_sayap_ibu',
        'email': 'sayap.ibu@ruangpeduli.id',
        'password': 'panti123',
        'nama_panti': 'Yayasan Sayap Ibu Cabang Banten',
        'alamat_panti': 'Jl. Raya Graha Utama No.33B',
        'nomor_panti': '(021)7331004',
        'description': 'Cabang Banten dari Yayasan Sayap Ibu, melayani anak-anak terlantar dan difabel sejak 1955.',
        'provinsi': 'Banten',
        'kabupaten_kota': 'Kota Tangerang Selatan',
        'kecamatan': 'Pondok Aren',
        'kelurahan': 'Pondok Kacang Barat',
        'kode_pos': '15226',
        'lat': -6.294000,
        'lng': 106.710100,
    },
]


class Command(BaseCommand):
    help = 'Seed / update 3 dummy panti asuhan accounts with full address detail'

    def handle(self, *args, **options):
        for data in PANTI_DATA:
            user, user_created = User.objects.get_or_create(
                username=data['username'],
                defaults={
                    'email': data['email'],
                    'role': 'panti',
                },
            )
            if user_created:
                user.set_password(data['password'])
                user.save()

            profile, profile_created = OrphanageProfile.objects.get_or_create(
                user=user,
                defaults={'nama_panti': data['nama_panti']},
            )

            # Always update address fields
            profile.nama_panti = data['nama_panti']
            profile.alamat_panti = data['alamat_panti']
            profile.nomor_panti = data['nomor_panti']
            profile.description = data['description']
            profile.provinsi = data['provinsi']
            profile.kabupaten_kota = data['kabupaten_kota']
            profile.kecamatan = data['kecamatan']
            profile.kelurahan = data['kelurahan']
            profile.kode_pos = data['kode_pos']
            profile.lat = data['lat']
            profile.lng = data['lng']
            profile.save()

            action = 'Created' if profile_created else 'Updated'
            self.stdout.write(self.style.SUCCESS(
                f"  {action}: {data['nama_panti']} "
                f"({data['kecamatan']}, {data['kabupaten_kota']}) "
                f"[{data['lat']}, {data['lng']}]"
            ))

        self.stdout.write(self.style.SUCCESS('\nDone.'))
