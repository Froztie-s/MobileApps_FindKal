from django.conf import settings
from django.core.mail import EmailMultiAlternatives
from django.db.models import Q
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

import math as _math
import random as _random
from django.utils import timezone as _tz
import datetime as _dt


def _haversine_km(lat1, lon1, lat2, lon2):
    """Return great-circle distance in kilometres between two coordinates."""
    R = 6371.0
    dlat = _math.radians(lat2 - lat1)
    dlon = _math.radians(lon2 - lon1)
    a = (_math.sin(dlat / 2) ** 2
         + _math.cos(_math.radians(lat1))
         * _math.cos(_math.radians(lat2))
         * _math.sin(dlon / 2) ** 2)
    return R * 2 * _math.asin(_math.sqrt(a))
from .models import (
    User, EmailVerification, PasswordResetToken, PendingEmailVerification,
    Unggahan, UnggahanImage, Bookmark,
    SurveyQuestion, SurveyAttempt, SURVEY_MAX_ATTEMPTS, SURVEY_LOCKOUT_DAYS,
    SavedTripPlan,
)


def _send_otp_email(email, code):
    subject = "Kode Verifikasi FindKal"
    plain_text = (
        f"Halo!\n\n"
        f"Berikut kode OTP untuk verifikasi akun kamu:\n\n"
        f"{code}\n\n"
        f"Kode ini berlaku selama 10 menit.\n"
        f"Jangan bagikan kode ini kepada siapapun.\n\n"
        f"Jika kamu tidak merasa mendaftar di FindKal, abaikan email ini."
    )
    html = f"""
    <!DOCTYPE html>
    <html lang="id">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    </head>
    <body style="margin:0;padding:0;background-color:#f4f4f4;font-family:'Helvetica Neue',Arial,sans-serif;">
      <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f4f4f4;padding:40px 0;">
        <tr>
          <td align="center">
            <table width="480" cellpadding="0" cellspacing="0"
                   style="background-color:#ffffff;border-radius:16px;overflow:hidden;
                          box-shadow:0 2px 12px rgba(0,0,0,0.08);">

              <!-- Header -->
              <tr>
                <td align="center"
                    style="background-color:#4AA5A6;padding:32px 40px 24px;">
                  <span style="font-size:28px;font-weight:800;color:#ffffff;
                               letter-spacing:1px;font-family:'Helvetica Neue',Arial,sans-serif;">
                    FindKal
                  </span>
                </td>
              </tr>

              <!-- Body -->
              <tr>
                <td style="padding:36px 40px 12px;">
                  <p style="margin:0 0 8px;font-size:16px;color:#333333;">
                    Halo! Berikut kode OTP untuk verifikasi akun kamu:
                  </p>
                </td>
              </tr>

              <!-- OTP Box -->
              <tr>
                <td align="center" style="padding:8px 40px 24px;">
                  <div style="background-color:#E8F6F6;border-radius:12px;
                              padding:20px 40px;display:inline-block;">
                    <span style="font-size:42px;font-weight:800;
                                 letter-spacing:12px;color:#4AA5A6;
                                 font-family:'Courier New',monospace;">
                      {code}
                    </span>
                  </div>
                </td>
              </tr>

              <!-- Info -->
              <tr>
                <td style="padding:0 40px 32px;">
                  <p style="margin:0 0 6px;font-size:14px;color:#555555;">
                    Kode ini berlaku selama <strong>10 menit</strong>.
                  </p>
                  <p style="margin:0;font-size:14px;color:#555555;">
                    Jangan bagikan kode ini kepada siapapun.
                  </p>
                </td>
              </tr>

              <!-- Divider -->
              <tr>
                <td style="padding:0 40px;">
                  <hr style="border:none;border-top:1px solid #eeeeee;margin:0;" />
                </td>
              </tr>

              <!-- Footer -->
              <tr>
                <td style="padding:20px 40px 32px;">
                  <p style="margin:0;font-size:12px;color:#aaaaaa;text-align:center;">
                    Jika kamu tidak merasa mendaftar di FindKal, abaikan email ini.
                  </p>
                </td>
              </tr>

            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
    """
    msg = EmailMultiAlternatives(
        subject=subject,
        body=plain_text,
        from_email=settings.DEFAULT_FROM_EMAIL,
        to=[email],
    )
    msg.attach_alternative(html, "text/html")
    msg.send(fail_silently=False)


# ---------------------------------------------------------------------------
# Registration â€” Send email verification OTP
# POST /api/register/send-verification/
# Body: { "email": "..." }
# ---------------------------------------------------------------------------
class RegisterSendVerificationView(APIView):
    def post(self, request):
        email = request.data.get("email", "").strip()
        if not email:
            return Response({"error": "Email wajib diisi."}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(email__iexact=email, is_email_verified=True).exists():
            return Response(
                {"error": "Email ini sudah terdaftar. Silakan masuk menggunakan akun kamu."},
                status=status.HTTP_409_CONFLICT,
            )

        # Invalidate any previous unused OTPs for this email
        PendingEmailVerification.objects.filter(
            email__iexact=email, is_used=False
        ).update(is_used=True)

        code = EmailVerification.generate_code()
        PendingEmailVerification.objects.create(email=email, code=code)
        try:
            _send_otp_email(email, code)
        except Exception as e:
            return Response(
                {"error": f"Gagal mengirim email verifikasi: {e}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        return Response({"detail": "Kode verifikasi dikirim ke email kamu."}, status=status.HTTP_200_OK)


# ---------------------------------------------------------------------------
# Registration â€” Verify email OTP
# POST /api/register/verify-email/
# Body: { "email": "...", "code": "123456" }
# ---------------------------------------------------------------------------
class RegisterVerifyEmailView(APIView):
    def post(self, request):
        email = request.data.get("email", "").strip()
        code = request.data.get("code", "").strip()

        if not email or not code:
            return Response({"error": "Email dan kode wajib diisi."}, status=status.HTTP_400_BAD_REQUEST)

        pending = (
            PendingEmailVerification.objects.filter(email__iexact=email, is_used=False)
            .order_by("-created_at")
            .first()
        )

        if not pending or not pending.verify(code):
            return Response(
                {"error": "Kode tidak valid atau sudah kedaluwarsa."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response({"detail": "Email berhasil diverifikasi."}, status=status.HTTP_200_OK)


# ---------------------------------------------------------------------------
# Registration â€” Create account
# POST /api/register/
# Body: { name, username, password, email, negara, provinsi, kota, kecamatan, kelurahan }
# ---------------------------------------------------------------------------
class RegisterView(APIView):
    def post(self, request):
        name     = request.data.get("name", "").strip()
        username = request.data.get("username", "").strip()
        password = request.data.get("password", "")
        email    = request.data.get("email", "").strip()
        negara   = request.data.get("negara", "").strip()
        provinsi = request.data.get("provinsi", "").strip()
        kota     = request.data.get("kota", "").strip()
        kecamatan = request.data.get("kecamatan", "").strip()
        kelurahan = request.data.get("kelurahan", "").strip()

        if not all([name, username, password, email, provinsi, kota, kecamatan, kelurahan]):
            return Response(
                {"error": "Semua field wajib diisi."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Confirm email was OTP-verified
        if not PendingEmailVerification.objects.filter(
            email__iexact=email, is_verified=True
        ).exists():
            return Response(
                {"error": "Email belum diverifikasi. Silakan verifikasi email terlebih dahulu."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Check email uniqueness â€” only block verified accounts
        if User.objects.filter(email__iexact=email, is_email_verified=True).exists():
            return Response(
                {"error": "Email ini sudah terdaftar. Silakan masuk menggunakan akun kamu."},
                status=status.HTTP_409_CONFLICT,
            )
        # Clean up any incomplete/unverified user with the same email
        User.objects.filter(email__iexact=email, is_email_verified=False).delete()

        # Check username uniqueness
        if User.objects.filter(username__iexact=username).exists():
            return Response(
                {"error": "Username sudah digunakan. Coba username lain."},
                status=status.HTTP_409_CONFLICT,
            )

        # Validate password strength
        try:
            validate_password(password)
        except ValidationError as e:
            return Response({"error": list(e.messages)}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create_user(
            email=email,
            name=name,
            password=password,
            username=username,
            negara=negara or "Indonesia",
            provinsi=provinsi,
            kota=kota,
            kecamatan=kecamatan,
            kelurahan=kelurahan,
            is_email_verified=True,
        )

        # Clean up the pending verification record
        PendingEmailVerification.objects.filter(email__iexact=email).delete()

        return Response(
            {"detail": f"Akun {user.username} berhasil dibuat."},
            status=status.HTTP_201_CREATED,
        )


# ---------------------------------------------------------------------------
# Step 1 â€” Find account
# POST /api/password-reset/request/
# Body: { "identifier": "<email_or_name>" }
# ---------------------------------------------------------------------------
class PasswordResetRequestView(APIView):
    def post(self, request):
        identifier = request.data.get("identifier", "").strip()
        if not identifier:
            return Response(
                {"error": "Masukkan username atau email."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Look up by email OR name (case-insensitive)
        user = User.objects.filter(
            Q(email__iexact=identifier) | Q(name__iexact=identifier)
        ).first()

        if not user:
            return Response(
                {"error": "Akun tidak ditemukan."},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Invalidate any previous unused reset OTPs for this user
        EmailVerification.objects.filter(
            user=user,
            purpose=EmailVerification.Purpose.RESET_PASSWORD,
            is_used=False,
        ).update(is_used=True)

        code = EmailVerification.generate_code()
        EmailVerification.objects.create(
            user=user,
            code=code,
            purpose=EmailVerification.Purpose.RESET_PASSWORD,
        )
        try:
            _send_otp_email(user.email, code)
        except Exception as e:
            return Response(
                {"error": f"Gagal mengirim email: {e}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        return Response(
            {"email": user.email},
            status=status.HTTP_200_OK,
        )


# ---------------------------------------------------------------------------
# Step 1b â€” Resend code
# POST /api/password-reset/resend/
# Body: { "email": "..." }
# ---------------------------------------------------------------------------
class PasswordResetResendView(APIView):
    def post(self, request):
        email = request.data.get("email", "").strip()
        user = User.objects.filter(email__iexact=email).first()
        if not user:
            return Response({"error": "Akun tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)

        # Invalidate old codes
        EmailVerification.objects.filter(
            user=user,
            purpose=EmailVerification.Purpose.RESET_PASSWORD,
            is_used=False,
        ).update(is_used=True)

        code = EmailVerification.generate_code()
        EmailVerification.objects.create(
            user=user,
            code=code,
            purpose=EmailVerification.Purpose.RESET_PASSWORD,
        )
        try:
            _send_otp_email(user.email, code)
        except Exception as e:
            return Response(
                {"error": f"Gagal mengirim email: {e}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        return Response(
            {"detail": "Kode baru sudah dikirim ulang melalui email. Segera cek inbox kamu."},
            status=status.HTTP_200_OK,
        )


# ---------------------------------------------------------------------------
# Step 2 â€” Verify OTP code
# POST /api/password-reset/verify-code/
# Body: { "email": "...", "code": "123456" }
# Returns: { "reset_token": "<uuid>" }
# ---------------------------------------------------------------------------
class PasswordResetVerifyCodeView(APIView):
    def post(self, request):
        email = request.data.get("email", "").strip()
        code = request.data.get("code", "").strip()

        if not email or not code:
            return Response(
                {"error": "Email dan kode wajib diisi."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = User.objects.filter(email__iexact=email).first()
        if not user:
            return Response({"error": "Akun tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)

        # Find the most recent unused reset OTP
        otp = (
            EmailVerification.objects.filter(
                user=user,
                purpose=EmailVerification.Purpose.RESET_PASSWORD,
                is_used=False,
            )
            .order_by("-created_at")
            .first()
        )

        if not otp or not otp.verify(code):
            return Response(
                {"error": "Kode tidak valid atau sudah kedaluwarsa."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Issue a short-lived reset token
        reset_token = PasswordResetToken.objects.create(user=user)

        return Response(
            {"reset_token": str(reset_token.token)},
            status=status.HTTP_200_OK,
        )


# ---------------------------------------------------------------------------
# Step 3 â€” Set new password
# POST /api/password-reset/confirm/
# Body: { "reset_token": "<uuid>", "new_password": "..." }
# ---------------------------------------------------------------------------
class PasswordResetConfirmView(APIView):
    def post(self, request):
        token_value = request.data.get("reset_token", "").strip()
        new_password = request.data.get("new_password", "")

        if not token_value or not new_password:
            return Response(
                {"error": "Token dan kata sandi baru wajib diisi."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            reset_token = PasswordResetToken.objects.select_related("user").get(
                token=token_value
            )
        except (PasswordResetToken.DoesNotExist, ValueError):
            return Response({"error": "Token tidak valid."}, status=status.HTTP_400_BAD_REQUEST)

        if not reset_token.is_valid():
            return Response(
                {"error": "Token sudah kedaluwarsa. Ulangi proses dari awal."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = reset_token.user
        try:
            validate_password(new_password, user=user)
        except ValidationError as e:
            return Response({"error": list(e.messages)}, status=status.HTTP_400_BAD_REQUEST)

        user.set_password(new_password)
        user.save(update_fields=["password"])

        reset_token.is_used = True
        reset_token.save(update_fields=["is_used"])

        return Response(
            {"detail": "Kata sandi berhasil diubah."},
            status=status.HTTP_200_OK,
        )

# ---------------------------------------------------------------------------
# Update profile
# PATCH /api/profile/update/<user_id>/
# Multipart form: name, bio, profile_photo (file), delete_photo (true/false)
# ---------------------------------------------------------------------------
class UpdateProfileView(APIView):
    def patch(self, request, user_id):
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({"error": "User tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)

        name = request.data.get('name')
        bio = request.data.get('bio')
        photo = request.FILES.get('profile_photo')
        delete_photo = request.data.get('delete_photo', '').lower() == 'true'

        if name is not None:
            user.name = name.strip()
        if bio is not None:
            user.bio = bio.strip()
        if delete_photo:
            if user.profile_photo:
                user.profile_photo.delete(save=False)
            user.profile_photo = None
        elif photo is not None:
            if user.profile_photo:
                user.profile_photo.delete(save=False)
            user.profile_photo = photo

        user.save()

        photo_url = request.build_absolute_uri(user.profile_photo.url) if user.profile_photo else None
        return Response({
            "message": "Profil berhasil diperbarui.",
            "user": {
                "id": user.id,
                "name": user.name,
                "username": user.username,
                "email": user.email,
                "bio": user.bio,
                "profile_photo": photo_url,
            }
        }, status=status.HTTP_200_OK)


class LoginView(APIView):
    def post(self, request):
        identifier = request.data.get("identifier", "").strip()
        password = request.data.get("password", "")

        if not identifier or not password:
            return Response({"error": "Username/Email dan kata sandi wajib diisi"}, status=status.HTTP_400_BAD_REQUEST)

        user = None
        if "@" in identifier:
            try:
                user = User.objects.get(email=identifier)
            except User.DoesNotExist:
                pass
        
        if not user:
            try:
                user = User.objects.get(username=identifier)
            except User.DoesNotExist:
                pass

        if user:
            if user.role not in ("user", "local"):
                return Response({"error": "Akun tidak memiliki akses yang sesuai."}, status=status.HTTP_403_FORBIDDEN)
            if user.check_password(password):
                photo_url = request.build_absolute_uri(user.profile_photo.url) if user.profile_photo else None
                # Fetch attempt info for the app
                try:
                    attempt = user.survey_attempt
                    attempts_used = attempt.attempts_used
                    locked_until = attempt.locked_until.isoformat() if attempt.locked_until else None
                except SurveyAttempt.DoesNotExist:
                    attempts_used = 0
                    locked_until = None
                return Response({
                    "message": "Berhasil masuk",
                    "user": {
                        "id": user.id,
                        "email": user.email,
                        "username": user.username,
                        "name": user.name,
                        "bio": user.bio,
                        "profile_photo": photo_url,
                        "is_warga_lokal": user.role == "local",
                        "warga_lokal_region": user.warga_lokal_region,
                        "attempts_used": attempts_used,
                        "locked_until": locked_until,
                    }
                }, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Kata sandi salah"}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response({"error": "Akun tidak ditemukan"}, status=status.HTTP_404_NOT_FOUND)


def _serialize_unggahan(unggahan, request):
    images = [
        request.build_absolute_uri(img.image.url)
        for img in unggahan.images.all()
    ]
    photo_url = (
        request.build_absolute_uri(unggahan.user.profile_photo.url)
        if unggahan.user.profile_photo else None
    )
    return {
        "id":              unggahan.id,
        "userId":          unggahan.user.id,
        "userName":        unggahan.user.name,
        "usernameHandle":  f"@{unggahan.user.username}",
        "userAvatar":      photo_url,
        "placeName":       unggahan.nama_tempat,
        "rating":          unggahan.rating,
        "address":         unggahan.alamat,
        "review":          unggahan.ulasan,
        "budget":          unggahan.budget,
        "imagePaths":      images,
        "createdAt":       unggahan.created_at.isoformat(),
        "latitude":        unggahan.latitude,
        "longitude":       unggahan.longitude,
    }


# ---------------------------------------------------------------------------
# List / Create unggahan
# GET  /api/unggahan/          — returns all unggahan (newest first)
# POST /api/unggahan/          — multipart: user_id, nama_tempat, alamat,
#                                ulasan, rating, budget, image (×1-4)
# ---------------------------------------------------------------------------
_NEARBY_RADIUS_KM = 15.0


class UnggahanListCreateView(APIView):
    def get(self, request):
        unggahans = Unggahan.objects.select_related("user").prefetch_related("images").all()

        # Optional proximity filter: ?lat=X&lng=Y
        # Posts with no coordinates are always included (location unknown).
        try:
            user_lat = float(request.query_params["lat"])
            user_lng = float(request.query_params["lng"])
            filtered = []
            for u in unggahans:
                if u.latitude is None or u.longitude is None:
                    filtered.append(u)
                elif _haversine_km(user_lat, user_lng, u.latitude, u.longitude) <= _NEARBY_RADIUS_KM:
                    filtered.append(u)
            unggahans = filtered
        except (KeyError, ValueError, TypeError):
            # No valid lat/lng provided — return all
            pass

        return Response([_serialize_unggahan(u, request) for u in unggahans])

    def post(self, request):
        user_id    = request.data.get("user_id")
        nama_tempat = request.data.get("nama_tempat", "").strip()
        alamat     = request.data.get("alamat", "").strip()
        ulasan     = request.data.get("ulasan", "").strip()
        rating     = request.data.get("rating")
        budget     = request.data.get("budget", "").strip()
        images     = request.FILES.getlist("image")

        if not all([user_id, nama_tempat, alamat, ulasan, rating, budget]):
            return Response({"error": "Semua field wajib diisi."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            rating = int(rating)
            if not (1 <= rating <= 5):
                raise ValueError
        except (ValueError, TypeError):
            return Response({"error": "Rating harus berupa angka 1–5."}, status=status.HTTP_400_BAD_REQUEST)

        if not images or len(images) > 4:
            return Response({"error": "Wajib mengunggah 1–4 gambar."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({"error": "User tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)

        unggahan = Unggahan.objects.create(
            user=user,
            nama_tempat=nama_tempat,
            alamat=alamat,
            ulasan=ulasan,
            rating=rating,
            budget=budget,
        )
        for i, img in enumerate(images):
            UnggahanImage.objects.create(unggahan=unggahan, image=img, order=i)

        return Response(_serialize_unggahan(unggahan, request), status=status.HTTP_201_CREATED)


# ---------------------------------------------------------------------------
# Retrieve / Delete single unggahan
# GET    /api/unggahan/<id>/
# DELETE /api/unggahan/<id>/   — only the owner (user_id in body/query)
# ---------------------------------------------------------------------------
class UnggahanDetailView(APIView):
    def _get_object(self, pk):
        try:
            return Unggahan.objects.select_related("user").prefetch_related("images").get(pk=pk)
        except Unggahan.DoesNotExist:
            return None

    def get(self, request, pk):
        unggahan = self._get_object(pk)
        if not unggahan:
            return Response({"error": "Unggahan tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)
        return Response(_serialize_unggahan(unggahan, request))

    def delete(self, request, pk):
        unggahan = self._get_object(pk)
        if not unggahan:
            return Response({"error": "Unggahan tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)

        user_id = request.data.get("user_id") or request.query_params.get("user_id")
        if str(unggahan.user.id) != str(user_id):
            return Response({"error": "Kamu tidak memiliki izin untuk menghapus unggahan ini."}, status=status.HTTP_403_FORBIDDEN)

        for img in unggahan.images.all():
            img.image.delete(save=False)
        unggahan.delete()
        return Response({"detail": "Unggahan berhasil dihapus."}, status=status.HTTP_200_OK)


# ---------------------------------------------------------------------------
# Bookmark endpoints
# GET    /api/bookmarks/?user_id=X  — list all bookmarks for a user
# POST   /api/bookmarks/            — body: {user_id, unggahan_id}
# DELETE /api/bookmarks/<unggahan_id>/?user_id=X — remove bookmark
# ---------------------------------------------------------------------------
class BookmarkListCreateView(APIView):
    def get(self, request):
        user_id = request.query_params.get("user_id")
        if not user_id:
            return Response({"error": "user_id wajib diisi."}, status=status.HTTP_400_BAD_REQUEST)
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({"error": "User tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)
        bookmarks = Bookmark.objects.filter(user=user).select_related("unggahan__user").prefetch_related("unggahan__images")
        return Response([_serialize_unggahan(b.unggahan, request) for b in bookmarks])

    def post(self, request):
        user_id = request.data.get("user_id")
        unggahan_id = request.data.get("unggahan_id")
        if not user_id or not unggahan_id:
            return Response({"error": "user_id dan unggahan_id wajib diisi."}, status=status.HTTP_400_BAD_REQUEST)
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({"error": "User tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)
        try:
            unggahan = Unggahan.objects.get(id=unggahan_id)
        except Unggahan.DoesNotExist:
            return Response({"error": "Unggahan tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)
        _, created = Bookmark.objects.get_or_create(user=user, unggahan=unggahan)
        if not created:
            return Response({"detail": "Sudah disimpan."}, status=status.HTTP_200_OK)
        return Response({"detail": "Disimpan ke Markah."}, status=status.HTTP_201_CREATED)


class BookmarkDeleteView(APIView):
    def delete(self, request, unggahan_id):
        user_id = request.data.get("user_id") or request.query_params.get("user_id")
        if not user_id:
            return Response({"error": "user_id wajib diisi."}, status=status.HTTP_400_BAD_REQUEST)
        deleted, _ = Bookmark.objects.filter(user_id=user_id, unggahan_id=unggahan_id).delete()
        if deleted:
            return Response({"detail": "Dihapus dari Markah."}, status=status.HTTP_200_OK)
        return Response({"error": "Bookmark tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)


# ---------------------------------------------------------------------------
# Survey endpoints
# GET  /api/survey/questions/  — returns 5 questions (4 fixed demo + 1 random)
# POST /api/survey/submit/     — body: {user_id, answers: [{question_id, selected_index}]}
# ---------------------------------------------------------------------------
class SurveyQuestionsView(APIView):
    def get(self, request):
        demo_qs = list(SurveyQuestion.objects.filter(is_demo=True))
        other_qs = list(SurveyQuestion.objects.filter(is_demo=False))

        selected = list(demo_qs)
        remaining_slots = max(0, 5 - len(selected))
        if remaining_slots > 0 and other_qs:
            selected += _random.sample(other_qs, min(remaining_slots, len(other_qs)))

        _random.shuffle(selected)

        data = [
            {
                "id": q.id,
                "question_text": q.question_text,
                "options": [q.option_a, q.option_b, q.option_c, q.option_d],
            }
            for q in selected
        ]
        return Response(data)


class SurveySubmitView(APIView):
    def post(self, request):
        user_id = request.data.get("user_id")
        answers = request.data.get("answers", [])
        region  = (request.data.get("region") or "").strip()

        if not user_id:
            return Response({"error": "user_id wajib diisi."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({"error": "User tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)

        # Already verified
        if user.role == "local":
            return Response({"passed": True, "score": 5, "already_verified": True})

        attempt, _ = SurveyAttempt.objects.get_or_create(user=user)

        # Check lockout
        if attempt.is_locked():
            return Response(
                {"error": "Akun dikunci sementara.", "locked_until": attempt.locked_until.isoformat()},
                status=status.HTTP_403_FORBIDDEN,
            )

        # Score answers
        score = 0
        for ans in answers:
            try:
                q = SurveyQuestion.objects.get(id=ans["question_id"])
                if int(ans["selected_index"]) == q.correct_index:
                    score += 1
            except (SurveyQuestion.DoesNotExist, KeyError, ValueError):
                pass

        attempt.attempts_used += 1
        attempt.last_attempt_at = _tz.now()

        if score >= 4:
            user.role = "local"
            if region:
                user.warga_lokal_region = region
            user.save(update_fields=["role", "warga_lokal_region"])
            attempt.save()
            return Response({"passed": True, "score": score, "region": user.warga_lokal_region})

        if attempt.attempts_used >= SURVEY_MAX_ATTEMPTS:
            attempt.locked_until = _tz.now() + _dt.timedelta(days=SURVEY_LOCKOUT_DAYS)
            attempt.save()
            return Response({
                "passed": False,
                "score": score,
                "locked_until": attempt.locked_until.isoformat(),
                "attempts_remaining": 0,
            })

        attempt.save()
        return Response({
            "passed": False,
            "score": score,
            "attempts_remaining": SURVEY_MAX_ATTEMPTS - attempt.attempts_used,
        })


# ---------------------------------------------------------------------------
# Trip Planner endpoint (rule-based, uses FindKal Unggahan data)
# POST /api/ai/trip-plan/
# Body: { province, city (optional), duration (days), budget_id, themes (optional list) }
# ---------------------------------------------------------------------------
_BUDGET_MAP = {
    "hemat":    ["Rp 1k - Rp 50k"],
    "budget":   ["Rp 50k - Rp 100k"],
    "menengah": ["Rp 100k - Rp 150k", "Rp 150k - Rp 200k"],
    "premium":  ["Rp 150k - Rp 200k", "Rp 250k+"],
    "luxury":   ["Rp 250k+"],
}

_BUDGET_LABELS = {
    "hemat":    "< Rp100.000",
    "budget":   "Rp100.000 – Rp300.000",
    "menengah": "Rp300.000 – Rp700.000",
    "premium":  "Rp700.000 – Rp1.500.000",
    "luxury":   "> Rp1.500.000",
}

# Keywords to match themes against nama_tempat and ulasan
_THEME_KEYWORDS = {
    "Nature":           ["park", "alam", "taman", "hutan", "pantai", "danau", "gunung", "bukit", "kebun", "square", "outdoor"],
    "Shopping":         ["mall", "aeon", "market", "shop", "plaza", "pasar", "store", "boutique"],
    "Wellness":         ["spa", "gym", "sport", "fitness", "yoga", "padel", "racquet", "tennis", "badminton", "renang", "kolam"],
    "Entertainment":    ["playground", "playtopia", "funtasia", "ocean park", "theme park", "wahana", "hiburan", "cinema", "bioskop"],
    "Food & drinks":    ["cafe", "kopi", "restoran", "restaurant", "kuliner", "makan", "bread", "bakery", "coffee", "bistro", "warung"],
    "Culture & History": ["museum", "heritage", "sejarah", "budaya", "monument", "tugu", "cultural", "library", "perpustakaan", "peringatan"],
}

_VISIT_TIMES = ["09.00 AM", "12.00 PM", "03.00 PM", "06.00 PM"]


class TripPlanView(APIView):
    def post(self, request):
        province  = (request.data.get("province") or "").strip()
        city      = (request.data.get("city") or "").strip()
        duration  = int(request.data.get("duration") or 1)
        budget_id = (request.data.get("budget_id") or "menengah").strip()
        themes    = request.data.get("themes") or []

        budget_choices = _BUDGET_MAP.get(budget_id, _BUDGET_MAP["menengah"])
        budget_label   = _BUDGET_LABELS.get(budget_id, "")

        # Build location filter
        loc_filter = Q()
        if city:
            loc_filter |= Q(alamat__icontains=city)
        if province:
            loc_filter |= Q(alamat__icontains=province)

        # Try filtered query first
        qs = Unggahan.objects.filter(loc_filter, budget__in=budget_choices).order_by("-rating")

        # Fall back to all posts (sorted by rating) if too few results
        if qs.count() < 3:
            qs = Unggahan.objects.all().order_by("-rating")

        # Filter by themes using keyword matching against nama_tempat + ulasan
        if themes:
            keywords = []
            for theme in themes:
                keywords.extend(_THEME_KEYWORDS.get(theme, []))

            if keywords:
                theme_filter = Q()
                for kw in keywords:
                    theme_filter |= Q(nama_tempat__icontains=kw) | Q(ulasan__icontains=kw)
                theme_qs = qs.filter(theme_filter)
                # Only apply theme filter if it yields enough results
                if theme_qs.count() >= 3:
                    qs = theme_qs

        # Deduplicate by nama_tempat (keep first = highest rated due to ordering)
        seen_names = set()
        deduped = []
        for u in qs:
            key = u.nama_tempat.lower().strip()
            if key not in seen_names:
                seen_names.add(key)
                deduped.append(u)

        # Take duration × 3 places, capped at 9
        max_places = min(duration * 3, 9)
        selected = deduped[:max_places]

        # Build place list
        places = []
        for idx, u in enumerate(selected):
            first_img = u.images.order_by("order").first()
            image_url = (
                request.build_absolute_uri(first_img.image.url)
                if first_img and first_img.image
                else None
            )
            time_label = _VISIT_TIMES[idx % len(_VISIT_TIMES)]
            detail_text = (u.ulasan[:120] + ("..." if len(u.ulasan) > 120 else ""))
            places.append({
                "time":      time_label,
                "title":     u.nama_tempat,
                "details":   f"{detail_text}\nBudget: {u.budget}",
                "image_url": image_url,
                "latitude":  u.latitude,
                "longitude": u.longitude,
            })

        location_label = city if city else province
        theme_label = ", ".join(themes) if themes else ""
        vibes = f"Perjalanan {duration} hari di {location_label} dengan budget {budget_label}"
        if theme_label:
            vibes += f", tema {theme_label}"

        return Response({
            "place_count":     len(places),
            "vibes":           vibes,
            "budget_summary":  budget_label,
            "places":          places,
        })


class SavedTripPlanView(APIView):
    def post(self, request):
        user_id   = request.data.get("user_id")
        name      = (request.data.get("name") or "").strip()
        duration  = (request.data.get("duration") or "1")
        image_url = (request.data.get("image_url") or "")
        places    = request.data.get("places") or []

        if not user_id or not name:
            return Response({"error": "user_id and name are required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

        trip = SavedTripPlan.objects.create(
            user=user,
            name=name,
            duration=str(duration),
            image_url=image_url,
            places=places,
        )
        return Response({"id": trip.pk}, status=status.HTTP_201_CREATED)

    def get(self, request):
        user_id = request.query_params.get("user_id")
        if not user_id:
            return Response({"error": "user_id is required."}, status=status.HTTP_400_BAD_REQUEST)

        def _rewrite_url(url):
            """Re-resolve a stored absolute media URL against the current request host."""
            if url and "/media/" in url:
                media_path = url[url.index("/media/"):]
                return request.build_absolute_uri(media_path)
            return url

        trips = SavedTripPlan.objects.filter(user_id=user_id)

        # Build a name→(lat, lng) lookup from current Unggahan data
        coord_lookup: dict = {}
        for u in Unggahan.objects.filter(
            latitude__isnull=False, longitude__isnull=False
        ).values("nama_tempat", "latitude", "longitude"):
            key = u["nama_tempat"].lower().strip()
            if key not in coord_lookup:
                coord_lookup[key] = (u["latitude"], u["longitude"])

        data = []
        for t in trips:
            places = []
            for p in (t.places or []):
                enriched = {**p, "image_url": _rewrite_url(p.get("image_url"))}
                # Fill in missing coordinates from current DB data
                if enriched.get("latitude") is None or enriched.get("longitude") is None:
                    key = (enriched.get("title") or "").lower().strip()
                    if key in coord_lookup:
                        enriched["latitude"], enriched["longitude"] = coord_lookup[key]
                places.append(enriched)
            data.append({
                "id":        t.pk,
                "name":      t.name,
                "duration":  t.duration,
                "image_url": _rewrite_url(t.image_url),
                "places":    places,
            })
        return Response(data)


class ChangeEmailRequestView(APIView):
    def post(self, request):
        user_id   = request.data.get("user_id")
        new_email = (request.data.get("new_email") or "").strip().lower()

        if not user_id or not new_email:
            return Response({"error": "user_id dan new_email wajib diisi."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return Response({"error": "Pengguna tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)

        if User.objects.filter(email=new_email).exclude(pk=user_id).exists():
            return Response({"error": "Email ini sudah digunakan oleh akun lain."}, status=status.HTTP_400_BAD_REQUEST)

        PendingEmailVerification.objects.filter(email=new_email, is_used=False).update(is_used=True)

        code = f"{__import__('random').randint(0, 999999):06d}"
        PendingEmailVerification.objects.create(email=new_email, code=code)

        try:
            _send_otp_email(new_email, code)
        except Exception:
            return Response({"error": "Gagal mengirim email verifikasi. Coba lagi."}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        return Response({"message": "Kode OTP telah dikirim ke email baru."})


class ChangeEmailConfirmView(APIView):
    def post(self, request):
        user_id   = request.data.get("user_id")
        new_email = (request.data.get("new_email") or "").strip().lower()
        code      = (request.data.get("code") or "").strip()

        if not user_id or not new_email or not code:
            return Response({"error": "user_id, new_email, dan code wajib diisi."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return Response({"error": "Pengguna tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)

        if User.objects.filter(email=new_email).exclude(pk=user_id).exists():
            return Response({"error": "Email ini sudah digunakan oleh akun lain."}, status=status.HTTP_400_BAD_REQUEST)

        pending = PendingEmailVerification.objects.filter(email=new_email, is_used=False).order_by("-created_at").first()
        if not pending or not pending.verify(code):
            return Response({"error": "Kode tidak valid atau sudah kedaluwarsa."}, status=status.HTTP_400_BAD_REQUEST)

        user.email = new_email
        user.save(update_fields=["email"])

        return Response({"message": "Email berhasil diubah.", "new_email": new_email})


# ---------------------------------------------------------------------------
# Change password (authenticated)
# POST /api/change-password/
# Body: { "user_id": int, "current_password": str, "new_password": str }
# ---------------------------------------------------------------------------
class ChangePasswordView(APIView):
    def post(self, request):
        user_id          = request.data.get("user_id")
        current_password = request.data.get("current_password", "")
        new_password     = request.data.get("new_password", "")

        if not user_id or not current_password or not new_password:
            return Response(
                {"error": "user_id, current_password, dan new_password wajib diisi."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            user = User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return Response({"error": "Pengguna tidak ditemukan."}, status=status.HTTP_404_NOT_FOUND)

        if not user.check_password(current_password):
            return Response({"error": "Kata sandi saat ini tidak sesuai."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            validate_password(new_password, user=user)
        except ValidationError as e:
            return Response({"error": list(e.messages)}, status=status.HTTP_400_BAD_REQUEST)

        user.set_password(new_password)
        user.save(update_fields=["password"])

        return Response({"detail": "Kata sandi berhasil diubah."}, status=status.HTTP_200_OK)


