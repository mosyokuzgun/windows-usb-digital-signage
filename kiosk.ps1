param([string]$HedefSurucu = "J")

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$HataTercihi = 'SilentlyContinue'

if (-not ([System.Management.Automation.PSTypeName]'PencereYoneticisi').Type) {
    $Win32Api = @'
    using System;
    using System.Runtime.InteropServices;
    public class PencereYoneticisi {
        [DllImport("user32.dll")]
        public static extern short GetAsyncKeyState(int tusKodu);
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr pencereHwnd);
        [DllImport("user32.dll")]
        public static extern bool SetWindowPos(IntPtr pencereHwnd, IntPtr konumSonrasi, int xKonumu, int yKonumu, int genislik, int yukseklik, uint bayraklar);
    }
'@
    Add-Type -TypeDefinition $Win32Api
}

$geciciHtmlYolu = "$env:TEMP\kiosk_oynatici.html"
$ArananEtiket = "ku2gun" 

$htmlSablonu = @'
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
body, html { margin: 0; padding: 0; width: 100%; height: 100%; background: black; overflow: hidden; cursor: none; }
.container { position: absolute; top: 0; left: 0; width: 100%; height: 100%; display: flex; justify-content: center; align-items: center; background: black; }
video, img { width: 100%; height: 100%; object-fit: contain; position: absolute; top: 0; left: 0; opacity: 0; transition: opacity 0.05s ease; }
video.active, img.active { opacity: 1; z-index: 2; }
</style>
</head>
<body>
<div class="container">
  <video id="v1" autoplay muted playsinline></video>
  <video id="v2" muted playsinline></video>
  <img id="img1" alt="">
</div>
<script>
const oynatmaListesi = __JS_DIZISI__;
let suankiIndex = 0;
const videoBir = document.getElementById('v1');
const videoIki = document.getElementById('v2');
const gorsel = document.getElementById('img1');
let suankiVideo = videoBir;
let arkadaYuklenenVideo = videoIki;
let zamanlayici = null;

function medyayiOynat(index) {
    if (oynatmaListesi.length === 0) return;
    if (index >= oynatmaListesi.length) index = 0;
    if (index < 0) index = oynatmaListesi.length - 1;
    suankiIndex = index;
    const ogeYolu = oynatmaListesi[suankiIndex];
    const resimMi = /\.(jpg|jpeg|png|bmp)$/i.test(ogeYolu);

    clearTimeout(zamanlayici);
    videoBir.pause();
    videoIki.pause();
    videoBir.removeAttribute('src');
    videoIki.removeAttribute('src');
    videoBir.load();
    videoIki.load();

    if (resimMi) {
        let gosterimSuresi = 10000; 
        const dosyaAdi = ogeYolu.split('/').pop();
        const eslesme = dosyaAdi.match(/_(\d+)(?:sn|s|sec)?\./i);
        if (eslesme && eslesme[1]) {
            gosterimSuresi = parseInt(eslesme[1], 10) * 1000;
        }

        gorsel.src = 'file:///' + ogeYolu;
        gorsel.classList.add('active');
        
        zamanlayici = setTimeout(() => {
            medyayiOynat(suankiIndex + 1);
        }, gosterimSuresi); 
    } else {
        let calanVideo = suankiVideo;
        let onbellekVideo = arkadaYuklenenVideo;
        
        calanVideo.src = 'file:///' + ogeYolu;
        calanVideo.load();
        
        let oynatmaSozu = calanVideo.play();
        if (oynatmaSozu !== undefined) {
            oynatmaSozu.then(() => {
                calanVideo.classList.add('active');
                let sonrakiIndex = (suankiIndex + 1) % oynatmaListesi.length;
                let sonrakiOge = oynatmaListesi[sonrakiIndex];
                if (!/\.(jpg|jpeg|png|bmp)$/i.test(sonrakiOge)) {
                    onbellekVideo.src = 'file:///' + sonrakiOge;
                    onbellekVideo.load();
                }
            }).catch(hata => {
                if(hata.name !== "AbortError") { medyayiOynat(suankiIndex + 1); }
            });
        }
        
        calanVideo.onended = () => {
            suankiVideo = onbellekVideo;
            arkadaYuklenenVideo = calanVideo;
            medyayiOynat(suankiIndex + 1);
        };
    }
}

document.addEventListener('keydown', (olay) => {
    if (olay.key === 'ArrowRight') { medyayiOynat(suankiIndex + 1); }
    else if (olay.key === 'ArrowLeft') { medyayiOynat(suankiIndex - 1); }
});

medyayiOynat(0);
</script>
</body>
</html>
'@

while ($true) {
    $bulunanBirim = Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.FileSystemLabel -eq $ArananEtiket }

    if (-not $bulunanBirim) {
        Write-Host "[BEKLEME] '$ArananEtiket' etiketli USB bellek bekleniyor..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
        continue
    }

    $surucuHarfi = $bulunanBirim.DriveLetter
    $surucuDizini = "${surucuHarfi}:\"
    
    if (-not (Test-Path $surucuDizini)) {
        Start-Sleep -Seconds 2
        continue
    }

    Write-Host "[BASARILI] Dogru USB ($surucuDizini) tespit edildi, medya taraniyor..." -ForegroundColor Green
    
    $desteklenenUzantilar = @('.mp4','.avi','.mkv','.mov','.wmv','.jpg','.jpeg','.png','.bmp')
    $bugununTarihi = Get-Date
    
    $medyaDosyalari = Get-ChildItem -Path $surucuDizini -File | Where-Object { 
        $desteklenenUzantilar -contains $_.Extension.ToLower() 
    } | ForEach-Object {
        $dosya = $_
        $dosyaAdi = $_.Name
        
        if ($dosyaAdi -match '_(\d{4})-(\d{2})-(\d{2})\.') {
            $yil = [int]$Matches[1]
            $ay = [int]$Matches[2]
            $gun = [int]$Matches[3]
            $sonGecerlilikTarihi = Get-Date -Year $yil -Month $ay -Day $gun -Hour 23 -Minute 59 -Second 59
            
            if ($bugununTarihi -gt $sonGecerlilikTarihi) {
                Write-Host "[ATLANDI] Suresi dolmus dosya: $dosyaAdi" -ForegroundColor DarkGray
                return 
            }
        }
        
        $dosya.FullName
    }
    
    if ($medyaDosyalari.Count -eq 0) {
        Write-Host "[UYARI] $surucuDizini dizininde gecerli/desteklenen medya bulunamadi, bekleniyor..." -ForegroundColor DarkYellow
        Start-Sleep -Seconds 5
        continue
    }
    
    $jsDiziElemanlari = $medyaDosyalari | ForEach-Object { '"' + $_.Replace('\', '/') + '"' }
    $jsDiziMetni = '[' + ($jsDiziElemanlari -join ',') + ']'
    
    $hazirHtmlIcerigi = $htmlSablonu.Replace('__JS_DIZISI__', $jsDiziMetni)
    $utf8BomsizKodlama = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($geciciHtmlYolu, $hazirHtmlIcerigi, $utf8BomsizKodlama)
    
    $chromeExeYolu = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    if (-not (Test-Path $chromeExeYolu)) { 
        $chromeExeYolu = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" 
    }
    
    $izoleProfilDizini = "$env:TEMP\ChromeKioskProfili"
    if (Test-Path $izoleProfilDizini) {
        Remove-Item -Path $izoleProfilDizini -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    $chromeParametreleri = @(
        "--app=`"$geciciHtmlYolu`"",
        "--kiosk",
        "--user-data-dir=`"$izoleProfilDizini`"",
        "--allow-file-access-from-files",            
        "--autoplay-policy=no-user-gesture-required",
        "--disable-infobars",                        
        "--disable-session-crashed-bubble"           
    )
    
    $calisanSurec = Start-Process -FilePath $chromeExeYolu -ArgumentList $chromeParametreleri -PassThru
    Write-Host "[AKTIF] Oynatma basladi. Yon tuslari ile gecis yapabilir, ESC ile cikabilirsiniz." -ForegroundColor Cyan
    
    Start-Sleep -Milliseconds 1500
    
    $pencereNesnesi = Get-Process -Id $calisanSurec.Id -ErrorAction SilentlyContinue
    if ($pencereNesnesi -and $pencereNesnesi.MainWindowHandle -ne [IntPtr]::Zero) {
        $pencereHandle = $pencereNesnesi.MainWindowHandle
        [PencereYoneticisi]::SetForegroundWindow($pencereHandle) | Out-Null
        $enUstKonum = [IntPtr]-1
        [PencereYoneticisi]::SetWindowPos($pencereHandle, $enUstKonum, 0, 0, 0, 0, 3) | Out-Null
    }

    $donguSayaci = 0
    while ($true) {
        Start-Sleep -Milliseconds 100
        
        $escBasildiMi = [PencereYoneticisi]::GetAsyncKeyState(27) -band 0x8000
        if ($escBasildiMi) {
            Write-Host "`n[CIKIS] ESC tusuna basildi. Sadece goruntuleme kapatiliyor..." -ForegroundColor Red
            if (-not $calisanSurec.HasExited) { Stop-Process -Id $calisanSurec.Id -Force }
            
            Write-Host "[BEKLEME] Yeniden baslatmak icin lutfen mevcut USB bellegi cikarin..." -ForegroundColor Yellow
            while (Test-Path $surucuDizini) {
                Start-Sleep -Seconds 1
            }
            Write-Host "[BILGI] Bellek cikarildi. Sistem yeni baglanti icin hazir." -ForegroundColor Green
            break
        }

        if ($calisanSurec.HasExited) {
            Write-Host "[BILGI] Tarayici kapandi, yeniden baslatilacak..." -ForegroundColor Yellow
            break
        }

        $donguSayaci += 100
        if ($donguSayaci -ge 1000) {
            $donguSayaci = 0
            if (-not (Test-Path $surucuDizini)) {
                Write-Host "[BILGI] USB bellek cikarildi. Oynatma durduruldu." -ForegroundColor Yellow
                if (-not $calisanSurec.HasExited) { Stop-Process -Id $calisanSurec.Id -Force }
                break
            }
        }
    }
}