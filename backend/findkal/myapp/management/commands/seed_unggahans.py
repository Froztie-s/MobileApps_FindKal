import shutil
from django.core.management.base import BaseCommand
from django.conf import settings
from myapp.models import User, Unggahan, UnggahanImage

DUMMY_DATA = [
    {
        "userName": "Wawanti",
        "username": "wawanti001",
        "placeName": "Bahasa Alam BSD",
        "rating": 4,
        "address": "The Green, Cluster Manhattan B7/17 BSD City, Cilenggang, Kec. Serpong, Kota Tangerang Selatan, Banten 15310",
        "review": "Makanan dan minumannya enak, manteppp dah pokoknyaaa... Harga juga okes... Ambiencenya gak kalah mantep, tenang dan ademmm...",
        "budget": "Rp 50k - Rp 100k",
        "images": ["ba1.jpg", "ba2.jpg", "ba3.jpg"],
    },
    {
        "userName": "Richard",
        "username": "user71726",
        "placeName": "Hygge Cafe BSD",
        "rating": 4,
        "address": "Jl. BSD Grand Boulevard, Sampora, Kec. Cisauk, Kabupaten Tangerang, Banten 15345",
        "review": "Favourite spot to go buat WFC dan ngeliatin pemandangan. Makanannya not bad and there are lots of options. Plenty of beverages options too. Servicenya lumayan, around 20 menit udah dateng makanannya. Definitely will go back here :)",
        "budget": "Rp 50k - Rp 100k",
        "images": ["hygge1.jpg", "hygge2.jpg", "hygge3.jpg", "hygge4.jpg"],
    },
    {
        "userName": "Sabine",
        "username": "vi_enrose9",
        "placeName": "Bear&Butter BSD",
        "rating": 5,
        "address": "Mall Ararasa BSD, Lantai Unit GC, Lengkong Kulon, Kec. Pagedangan, Kabupaten Tangerang, Banten 15331",
        "review": "Kafenya lucu, estetik, dan mewah yang aku temukan dekat rumah. Mereka menyajikan kopi yang enak dan berbagai varian salt bread dengan rasa yang lezat.",
        "budget": "Rp 50k - Rp 100k",
        "images": ["bnb1.jpg", "bnb2.jpg", "bnb3.jpg"],
    },
    {
        "userName": "Kaatiya",
        "username": "aim2love",
        "placeName": "Artirasa Gading Serpong",
        "rating": 5,
        "address": "Ruko, Jl. Goldfinch Raya Jl. Springs Boulevard.31, Blok SGD No.30, Kabupaten Tangerang, Banten 15810",
        "review": "menurutku enak, tapi bukan yang enak banget. yang jelas menurutku masih best menu cheesecakenya",
        "budget": "Rp 1k - Rp 50k",
        "images": ["artirasa1.jpg", "artirasa2.jpg", "artirasa3.jpg"],
    },
    {
        "userName": "Sanca Jill",
        "username": "kitticatto",
        "placeName": "Salt Bread from Seoul BSD",
        "rating": 4,
        "address": "PJ7G+473 Zena at The Mozia M5, Jl. Lkr. Botanika Selatan No.1, Lengkong Kulon, Pagedangan, BSD City, Banten 15331",
        "review": "Salah satu salt bread terenak yang udah aku coba! Luarnya crunchy dalemnya lembut. Untuk varian original bener-bener kerasa butternya dan crunchy bagian luarnya.",
        "budget": "Rp 1k - Rp 50k",
        "images": ["sbseoul1.jpg", "sbseoul2.jpg"],
    },
]


class Command(BaseCommand):
    help = "Seed the database with dummy unggahan data from Flutter assets"

    def handle(self, *args, **options):
        assets_dir = settings.BASE_DIR.parent.parent / "frontend" / "assets" / "images"
        media_dir = settings.MEDIA_ROOT / "unggahan_images"
        media_dir.mkdir(parents=True, exist_ok=True)

        for data in DUMMY_DATA:
            user, created = User.objects.get_or_create(
                username=data["username"],
                defaults={
                    "name": data["userName"],
                    "email": f"{data['username']}@demo.com",
                    "is_email_verified": True,
                },
            )
            if created:
                user.set_password("demo1234")
                user.save()
                self.stdout.write(f"  Created user: {user.username}")

            if Unggahan.objects.filter(user=user, nama_tempat=data["placeName"]).exists():
                self.stdout.write(f"  Skipping '{data['placeName']}' (already exists)")
                continue

            unggahan = Unggahan.objects.create(
                user=user,
                nama_tempat=data["placeName"],
                alamat=data["address"],
                ulasan=data["review"],
                rating=data["rating"],
                budget=data["budget"],
            )

            for i, img_name in enumerate(data["images"]):
                src = assets_dir / img_name
                if src.exists():
                    dest_name = f"{user.username}_{img_name}"
                    shutil.copy2(str(src), str(media_dir / dest_name))
                    UnggahanImage.objects.create(
                        unggahan=unggahan,
                        image=f"unggahan_images/{dest_name}",
                        order=i,
                    )

            self.stdout.write(f"  Seeded: {data['placeName']}")

        self.stdout.write(self.style.SUCCESS("Done! Run the app and check /api/unggahan/"))
