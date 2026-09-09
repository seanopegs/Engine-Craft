===================================================================
PETUNJUK EDIT LEVEL MAZE (.TXT) - ENGINE-CRAFT: ECHO & SIGHT
===================================================================

Anda dapat mengubah atau membuat level baru dengan sangat mudah!
Cukup buka file level_1.txt sampai level_5.txt dengan Notepad.

Daftar Simbol Karakter:
-------------------------------------------------------------------
#  : Tembok / Dinding (Solid, tidak bisa dilewati)
.  : Lantai Kosong (Bisa dilewati)
     (Spasi ' ' juga dihitung sebagai lantai kosong)
P  : Posisi Awal Kedua Karakter (Blind & Deaf mulai bersama)
A  : Posisi Awal Karakter Buta (Blind / Kuro)
B  : Posisi Awal Karakter Tuli (Deaf / Shiro)
E  : Pintu Keluar / Finish Portal (Tujuan level)
M  : Titik Spawn & Patroli Monster Pemburu

Kunci & Pintu:
-------------------------------------------------------------------
R  : Kunci Merah (Visual Key - dilihat jelas oleh Karakter Tuli)
r  : Pintu Merah (Terbuka jika punya Kunci Merah)
S  : Kunci Suara (Sound Chime - terdeteksi sonar Karakter Buta)
s  : Pintu Suara (Terbuka jika punya Kunci Suara)
K  : Kunci Biru (Crystal Key)
k  : Pintu Biru (Terbuka jika punya Kunci Biru)

Jebakan & Mekanik:
-------------------------------------------------------------------
L  : Laser Trap (Jebakan mematikan; terlihat jelas oleh Deaf)
O  : Pressure Plate (Tombol lantai pengaktif gerbang)
G  : Gate / Gerbang (Membuka jika tombol O diinjak)
===================================================================

ATURAN KAMPANYE BARU
- Semua baris sama panjang; seluruh tepi harus #. Peta tidak valid ditolak.
- E membutuhkan kedua karakter berada di portal bersamaan.
- R hanya diambil Sight aktif; S hanya diambil Echo aktif; K oleh karakter aktif mana pun.
- Kunci dibagi bersama, dikonsumsi satu kali per pintu, pintu tetap terbuka.
- O adalah relay berpasangan: tepat dua pelat harus diinjak pemain bersamaan.
  F mematikan ikuti untuk menahan posisi. Semua G terkunci terbuka permanen
  setelah relay berhasil. Monster tidak dapat mengaktifkannya.
- L: aktif merah 2 detik, aman hijau 3 detik; 0,8 detik terakhir menjadi kuning.
  Seluruh kotak berbahaya saat merah, termasuk jika pemain diam di dalamnya.
- Setiap pintu kampanye merupakan satu-satunya penghubung antar sektor.
- Level 1: dua kunci dan pergantian karakter. Level 2: timing laser.
  Level 3: arena pemburu dengan jalur mengitari pilar. Level 4: relay pasangan.
  Level 5: relay, tiga warna pintu, laser, dan arena pemburu terakhir.
- level_tutorial.txt adalah contoh latihan terpisah, bukan bagian pilihan 1-5.
- Jalankan tests/verify_game.gd setelah mengedit peta (lihat tests/README.md).
