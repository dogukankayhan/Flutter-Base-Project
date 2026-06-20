## Bu PR ne yapar?

<!-- Tek cümleyle özetle -->

---

## Değişiklik tipi

- [ ] Yeni özellik (`feat`)
- [ ] Bug fix (`fix`)
- [ ] Refactoring
- [ ] Dokümantasyon
- [ ] CI/CD / altyapı
- [ ] Test ekleme / güncelleme

---

## Checklist

### Kod kalitesi
- [ ] `melos analyze` — uyarı/hata yok
- [ ] `melos test` — tüm testler geçiyor
- [ ] `melos format:check` — format hatası yok

### İçerik
- [ ] Yeni Bloc/Cubit için test dosyası eklendi
- [ ] Yeni API path'ler hard-code edilmedi (constructor parametresi veya sabit sınıf kullanıldı)
- [ ] Yeni UI bileşenleri `AppTextField`, `AppButton`, `AppCard` gibi mevcut component'ları kullanıyor
- [ ] Hard-coded string yok (lokalize edilmiş veya constant)
- [ ] Credential veya secret commit edilmedi

### Dokümantasyon
- [ ] Mimari değişiklik varsa `docs/ARCHITECTURE.md` güncellendi
- [ ] Yeni paket eklendiyse `CONTRIBUTING.md` güncellendi

---

## Test planı

<!-- Bu değişikliği nasıl test ettin? Hangi senaryoları kapsıyorsun? -->

---

## İlgili issue

Closes #
