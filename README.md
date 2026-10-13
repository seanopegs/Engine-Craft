# Engine-Craft: Echo & Sight

Game puzzle labirin 2D di Godot dengan dua karakter, Echo dan Sight.
Pemain berganti karakter untuk mengambil kunci, melewati pintu dan laser,
mengaktifkan relay, lalu membawa keduanya ke portal keluar.

## Menjalankan

1. Impor `project.godot` di Godot 4.7, versi yang tercatat di konfigurasi proyek.
2. Jalankan proyek dengan `F5`; scene awal adalah `scenes/main_menu.tscn`.

Source dan aset yang dibutuhkan editor ada di repo. Folder cache `.godot`
dapat dibuat kembali oleh editor saat impor.

## Level dan pemeriksaan

Kampanye menggunakan lima peta teks di `levels/`. Petunjuk simbol dan aturan
tersedia di [panduan level](levels/README_LEVEL_EDITOR.txt).

Pemeriksaan struktur peta dan beberapa perilaku runtime tersedia di
[`tests/verify_game.gd`](tests/verify_game.gd):

```sh
godot --headless --path . --script tests/verify_game.gd
```

Lihat [panduan pemeriksaan](tests/README.md) untuk cakupan dan preview UI.
Pemeriksaan ini tidak membuktikan semua pertemuan monster atau strategi pemain
sudah seimbang.
