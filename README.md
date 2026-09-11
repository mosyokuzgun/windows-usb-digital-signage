# Windows USB Kiosk Media Player

PowerShell ve Google Chrome tabanlı, harici depolama birimlerini (USB) otomatik etiket taramasıyla algılayan ve yerel diske senkronize ederek kesintisiz yayın yapan endüstriyel tip Windows dijital tabela (digital signage) çözümü.

## Özellikler

* **Otomatik Etiket Algılama:** Belirtilen etiket adına sahip USB diski harf bağımsız olarak arka planda tarar ve bulduğunda içeriği yerel diske senkronize eder.
* **Çevrimdışı Çalışma (Offline Mode):** USB bellek çıkarılsa veya takılı olmasa bile sistem daha önceden senkronize edilen yerel depodaki (`C:\KioskMedyaDeposu`) son içeriklerle yayına kesintisiz devam eder.
* **Kesintisiz Video Geçişi (Dual Preload):** Çift video etiketi (`v1` / `v2`) mimarisi sayesinde videolar arası geçişte siyah ekran veya donma yaşanmaz.
* **Dinamik Süre Okuma:** Resimlerin ekranda kalma süresini dosya adı üzerinden saniyelerle özelleştirebilirsiniz (Örn: `kampanya_15sn.jpg`).
* **Otomatik Bitiş Tarihi Filtreleme:** Belirli bir tarihten sonra gösterimden kalkması gereken medyaları dosya adına tarih ekleyerek otomatik pas geçebilirsiniz (Örn: `duyuru_2026-12-31.jpg`).
* **Akıllı ESC ve Otobakım Zamanlayıcısı:** `ESC` tuşu ile kiosk modundan çıkıldığında sistem hemen yeniden açılmaz; arka planda 3 dakikalık bir güvenlik sayacı başlatarak unutulma riskine karşı otomatik olarak tekrar yayına döner.
* **Pencere Kilidi (TopMost):** Windows API entegrasyonu ile Chrome penceresi her zaman en önde kalır, görev çubuğu veya bildirimler önüne geçemez.

## Dosya İsimlendirme Kuralları

Medya dosyalarınızı USB içerisine koyarken şu ekleri kullanabilirsiniz:

* **Özel Süre:** `dosya_adi_15sn.jpg` (10 saniyelik öntanımlı süre yerine 15 saniye kalır).
* **Bitiş Tarihi:** `dosya_adi_2026-12-31.jpg` (Yıl-Ay-Gün formatında belirtilen tarihten sonra oynatma listesinden otomatik çıkarılır).

## Kurulum ve Kullanım

1. Projedeki `kiosk.ps1` dosyasını uygun bir dizine yerleştirin.
2. USB belleğinizin etiket (Volume Label) adını $ArananEtiket fonksiyonundan ayarlayın.
3. Desteklenen medya dosyalarını (`.mp4`, `.avi`, `.mkv`, `.jpg`, `.png`, vb.) USB belleğe atın.
4. PowerShell üzerinden veya bir `.bat` dosyası ile betiği çalıştırarak sistemi başlatın.
