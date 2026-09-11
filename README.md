# Windows USB Kiosk Media Player

PowerShell ve Google Chrome tabanlı, harici depolama birimlerini (USB) otomatik algılayan, sıfır yapılandırma gerektiren hafif ve kararlı dijital tabela (digital signage) çözümü.

## Özellikler

* **Otomatik USB Algılama:** Belirtilen etiket adına sahip USB diski arka planda tarar ve bulduğunda oynatmayı başlatır; çıkarıldığında ekranı kapatır.
* **Kesintisiz Video Geçişi (Dual Preload):** Çift video etiketi (`v1` / `v2`) mimarisi sayesinde videolar arası geçişte siyah ekran veya donma yaşanmaz.
* **Dinamik Süre Okuma:** Resimlerin ekranda kalma süresini dosya adı üzerinden saniyelerle özelleştirebilirsiniz (Örn: `kampanya_15sn.jpg`).
* **Otomatik Bitiş Tarihi Filtreleme:** Belirli bir tarihten sonra gösterimden kalkması gereken medyaları dosya adına tarih ekleyerek otomatik pas geçebilirsiniz (Örn: `duyuru_2026-12-31.jpg`).
* **Klavye Kontrolleri:** Yön tuşları (`Sol/Sağ`) ile önceki ve sonraki medyaya manuel geçiş yapabilir, `ESC` tuşu ile kiosk modundan güvenle çıkabilirsiniz.
* **Pencere Kilidi (TopMost):** Windows API entegrasyonu ile Chrome penceresi her zaman en önde kalır, arka plana düşmez veya görev çubuğu önüne geçemez.

## Dosya İsimlendirme Kuralları

Medya dosyalarınızı USB içerisine koyarken şu ekleri kullanabilirsiniz:
* **Özel Süre:** `dosya_adi_15sn.jpg` (10 saniyelik öntanımlı süre yerine 15 saniye kalır).
* **Bitiş Tarihi:** `dosya_adi_2026-12-31.jpg` (Yıl-Ay-Gün formatında belirtilen tarihten sonra oynatma listesinden otomatik çıkarılır).
* **İkisi Bir Arada:** `kampanya_5sn_2026-06-01.jpg`

## Kurulum ve Kullanım

1. Projedeki `kiosk.ps1` ve `run.bat` dosyalarını aynı dizine yerleştirin.
2. USB belleğinizin etiket (Volume Label) adını ayarlayın. ($ArananEtiket)
3. Desteklenen medya dosyalarını (`.mp4`, `.avi`, `.mkv`, `.jpg`, `.png`, vb.) USB belleğe atın.
4. **`run.bat`** dosyasını çalıştırarak sistemi başlatın.
