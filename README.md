# 📋 İş Başvurum

> Flutter ile geliştirilmiş, Google hesabınız üzerinden otomatik iş başvurusu göndermenizi sağlayan kişisel kariyer otomasyon uygulaması.

---

## 🚀 Ne Yapar?

Hedeflediğiniz şirketleri kaydedin, mail şablonları oluşturun ve tek tıkla kişiselleştirilmiş başvuru maili gönderin. Tüm geçmiş başvurularınızı takip edin, mülakat davetlerini kaydedin.

---

## 🛠️ Teknoloji Yığını

| Katman | Teknoloji |
|---|---|
| Frontend | Flutter (Android & iOS) |
| Auth | Firebase Auth + Google Sign-In |
| Veritabanı | Cloud Firestore |
| Dosya Depolama | Firebase Storage |
| Mail Gönderimi | Gmail API (OAuth2 via googleapis) |

---

## 📱 Ekran Mimarisi

### 1. Giriş (Login)
- Google ile tek tıkla giriş
- Firebase Auth + Google Sign-In OAuth akışı
- İlk girişte onboarding ekranına yönlendirme

### 2. Profil Kurulumu (Onboarding)
- Telefon, GitHub URL, Portfolio URL girişi
- CV yükleme (PDF — Firebase Storage: `cvs/{uid}.pdf`)
- `is_profile_complete: false` iken zorunlu ekran

### 3. Dashboard
- Toplam başvuru sayısı, mülakat daveti oranı
- Haftalık başvuru yoğunluğu (line chart)
- Oyun / Mobil / Genel şablonlarına hızlı erişim butonları

### 4. Firmalar (CRM)
- Şirket kartları: ad, sektör etiketi, İK sorumlusu
- Sektör bazlı filtreleme (Oyun, Mobil, Web, AI...)
- Modal ile hızlı firma ekleme

### 5. Mail Şablonları
- HTML şablon editörü + canlı önizleme
- Desteklenen değişkenler:
  - `{{firma_adi}}` `{{ik_ismi}}` `{{aday_adi}}` `{{aday_telefon}}`
- Sektöre göre şablon etiketleme

### 6. Başvuru Gönderimi
- Seçilen firmanın sektörüne göre otomatik şablon eşleşmesi
- Değişkenlerin dinamik olarak doldurulması
- Varsayılan CV veya o başvuruya özel PDF seçimi
- Gmail API üzerinden gönderim (şifresiz, OAuth2 ile)

### 7. Başvurularım (Log)
- Gönderilen her mailin içeriği, zaman damgası, alıcı bilgisi
- Durum güncelleme: `Beklemede` → `Mülakat` → `Red` / `Kabul`

### 8. Ayarlar
- CV güncelleme
- Portfolio linki düzenleme
- Gmail API bağlantı durumu

---

## 🗄️ Veri Modeli (Firestore)

### `users`
```
uid, ad_soyad, email, cv_url, is_profile_complete, gmail_access_token
```

### `companies`
```
id, user_id, ad, sektor, ik_sorumlusu, web_sitesi
```

### `templates`
```
id, user_id, baslik, html_icerik, sektor_tipi
```

### `applications`
```
id, user_id, company_id, template_id, tarih, durum, mail_icerigi
```

---

## 🔐 Auth Akışı

```
Google Sign-In
     ↓
Firebase Auth (token)
     ↓
Gmail API OAuth2 izni istenir (mail gönderme scope'u)
     ↓
Token Firestore'a kaydedilir
     ↓
Başvuru gönderiminde Gmail API kullanılır
```

> Kullanıcıdan asla şifre istenmez. Tüm mail gönderimi Google'ın resmi OAuth2 altyapısı üzerinden gerçekleşir.

---

## 📦 Kurulum

```bash
git clone https://github.com/kaeruishere/isbasvurum.git
cd isbasvurum
flutter pub get
flutterfire configure
flutter run
```

---

## 📁 Klasör Yapısı

```
lib/
├── main.dart
├── screens/
│   ├── login_screen.dart
│   ├── onboarding_screen.dart
│   ├── dashboard_screen.dart
│   ├── companies_screen.dart
│   ├── templates_screen.dart
│   ├── apply_screen.dart
│   ├── applications_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── gmail_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
└── models/
    ├── company.dart
    ├── template.dart
    └── application.dart
```

---

## 🗺️ Yol Haritası

- [x] Google Sign-In ile kimlik doğrulama
- [ ] Onboarding ekranı
- [ ] Gmail API entegrasyonu
- [ ] Firma yönetimi (CRM)
- [ ] Şablon editörü
- [ ] Başvuru gönderimi
- [ ] Başvuru geçmişi ve durum takibi
- [ ] Dashboard istatistikleri

---

## 👤 Geliştirici

**Kaeru (Umut Eren Kaplan)**
[github.com/kaeruishere](https://github.com/kaeruishere) · [errenn.com](https://errenn.com)
