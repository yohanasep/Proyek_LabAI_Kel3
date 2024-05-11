% note: jika ada cara yang lebih efektif yang bisa diperbaiki dari kode2 dibawah boleh sekali di ubah ges, 
% tapi yang kode lama dikomen atau disimpan ya, jgn hapus total. kali aja butuh soalnyaa.

% rule untuk menentukan skala lahan, not very necessary but aint that bad either wkkwkw
skalaContainer(VolumeContainer, Skala) :- 
                        (not(number(VolumeContainer)) -> write('Volume container harus dalam bentuk angka!'), fail ;
                        VolumeContainer < 0 -> write('Volume container tidak boleh bernilai negatif!'), fail ;
                        VolumeContainer = 0 -> write('Volume container tidak boleh kosong!'), fail ;
                        VolumeContainer > 0, VolumeContainer =< 50 -> Skala = 'Kecil' ;
                        VolumeContainer > 50, VolumeContainer =< 500 -> Skala = 'Menegah' ;
                        Skala = 'Besar').

% input volume container
input_container(VolumeContainer) :- 
                        write('Berapa volume container Anda (dalam liter)? '), read(VolumeContainer), 
                        skalaContainer(VolumeContainer, Skala), write('Container tersebut cocok untuk lahan dengan skala '), 
                        write(Skala), nl, nl.

% input volume air yang dibutuhkan untuk 1 saluran irigasi
input_vol_1_irigasi(Volume1Irigasi) :- 
                        write('Berapa volume air yang dibutuhkan 1 saluran irigasi Anda (dalam liter)? '), 
                        read(Volume1Irigasi), nl.

% input banyaknya total irigasi yang dipunya di lahan itu
input_jlh_irigasi(JumlahIrigasi) :- write('Berapa jumlah total irigasi pada lahan anda? '), read(JumlahIrigasi), nl.

% base case
cek_kecukupan_air(_, JumlahIrigasi, JumlahIrigasi, _, Hasil) :- !, Hasil='Cukup', write(Hasil).

% base case
cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, _, VolumeContainer, Hasil) :- 
                        VolumeContainer < Volume1Irigasi, JumlahIrigasi =\= 0, !, 
                        Hasil='Tidak Cukup', write(Hasil).

% Pertama di cek dulu volume di container lebih besar atau sama ga dengan volume yang dibutuhkan untuk 1 saluran irigasi
% Kalo memenuhi, maka untuk saluran irigasi pertama kita isi (dengan mengurangkan volume dalam container sebanyak volume 1 saluran irigasi)
% next hitung berapa irigasi yang sudah di-air-i
% lalu panggil rule nya sendiri (untuk rekursif) dengan parameter yang sudah berubah besarannya
cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, JumlahIrigasi1, VolumeContainer, Hasil) :- 
                        VolumeContainer >= Volume1Irigasi,
                        SisaAir is VolumeContainer - Volume1Irigasi,
                        IrigasiYangSudahDiAiri is JumlahIrigasi1 + 1,
                        cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, IrigasiYangSudahDiAiri, SisaAir, Hasil).


% < -- -needs to be done NEEDS TO BE DONE NEEDS TO BE DONE NEEDS TO BE DONE NEEDS TO BE DONE needs to be done- -->
% < -- -needs to be done NEEDS TO BE DONE NEEDS TO BE DONE NEEDS TO BE DONE NEEDS TO BE DONE needs to be done- -->
% < -- -needs to be done NEEDS TO BE DONE NEEDS TO BE DONE NEEDS TO BE DONE NEEDS TO BE DONE needs to be done- -->

input_musim(Musim, SkorMusim) :- write('Bagaimana musim pada kawasan lahan saat ini (kemarau/hujan)? '), read(Musim), 
                        (Musim = hujan -> SkorMusim is 1 ;
                        Musim = kemarau -> SkorMusim is 2 ;
                        write('Musim tidak valid'), fail).

input_kelembaban(Kelembaban, SkorKelembaban) :- write('Berapa persentase kelembaban udara di sekitar lahan saat ini (%)? '), read(Kelembaban),
                        (Kelembaban > 60 -> SkorKelembaban is 1;
                        (Kelembaban >= 30, Kelembaban =< 60) -> SkorKelembaban is 2; 
                        Kelembaban < 30 -> SkorKelembaban is 3).

input_suhu(Suhu, SkorSuhu) :- write('Berapa suhu di sekitar lahan saat ini (°C)? '), read(Suhu),
                        (Suhu > 35 -> SkorSuhu is 3;
                        (Suhu >= 25, Suhu =< 35) -> SkorSuhu is 2;
                        Suhu < 25 -> SkorSuhu is 1).

input_pH_tanah(Ph, Sifat) :- write('Berapa pH tanah lahan saat ini (1-14)? '), read(Ph),
                        (Ph > 0, Ph =< 6 -> Sifat = 'Asam' ;
                        Ph == 7 -> Sifat = 'Netral' ;
                        Ph > 7, Ph =< 14 -> Sifat = 'Basa' ;
                        write('pH tidak valid'), fail), skorPH(Sifat, _).

skorPH(Sifat, SkorPH) :- (Sifat = 'Asam' -> SkorPH is 3;
                        Sifat = 'Netral' -> SkorPH is 2;
                        Sifat = 'Basa' -> SkorPH is 1).

cek_keperluan_penyiraman :- input_musim(_, SkorMusim), input_kelembaban(_, SkorKelembaban), 
                        SkorTotal is SkorMusim + SkorKelembaban, 
                        (SkorTotal >= 4 -> hitung_banyak_air_diperlukan;
                        SkorTotal < 4 -> fail).

hitung_banyak_air_diperlukan :- input_suhu(_, SkorSuhu), input_pH_tanah(_, Sifat), skorPH(Sifat, SkorPH),
                        SkorTotal is SkorSuhu + SkorPH;
                        (SkorTotal > 5 -> assert(high) ;
                        SkorTotal >= 5, SkorTotal >= 5 -> assert(mid) ;
                        SkorTotal < 5 -> assert(low)).

jenis_penyiraman(Tumbuhan, Skor) :- 
                        informasi_umum(Tumbuhan, Info),
                        (member('Penyerapan air banyak', Info) ; member('Penyerapan air normal', Info) -> Skor = 2 ;
                        member('Penyerapan air sedikit', Info) -> Skor = 1).

% tingkat_kebutuhan_air(Tumbuhan, Suhu, Kelembaban, CurahHujan, PH, KebutuhanAir) :-
%                   (Suhu > 35 -> SkorSuhu is 3;
%                   (Suhu >= 25, Suhu =< 35) -> SkorSuhu is 2;
%                   Suhu < 25 -> SkorSuhu is 1),
%                   (Kelembaban > 75 -> SkorKelembaban is 3;
%                   (Kelembaban >= 50, Kelembaban =< 75) -> SkorKelembaban is 2; 
%                   Kelembaban < 50 -> SkorKelembaban is 1), 
%                   (CurahHujan > 20 -> SkorCurahHujan is 3;
%                   (CurahHujan >= 5, CurahHujan =< 20) -> SkorCurahHujan is 2;
%                   CurahHujan < 5 -> SkorCurahHujan is 1), 
%                   (PH > 6.5 -> SkorPH is 3; 
%                   (PH >= 6.0, PH =< 6.5) -> SkorPH is 2; 
%                   PH < 6.0 -> SkorPH is 1),
%                   TotalScore is SkorSuhu + SkorKelembaban + SkorCurahHujan + SkorPH,
%                   (TotalScore >= 12 -> KebutuhanAir = 'high';
%                   (TotalScore >= 8, TotalScore < 12) -> KebutuhanAir = 'middle';
%                   TotalScore < 8 -> KebutuhanAir = 'low').



menus([]) :- !.
menus([Head | Tail]) :- write(Head), nl, menus(Tail).
input_menu(Pilihan, List) :- write("<< -- Sistem Penyiraman Tanaman Otomatis -- >>"), nl, write("Pilih menu: "), nl, 
                        List = ['1. Lihat kecukupan air di container', '2. Lihat informasi mengenai tanaman', 
                        '3. Apakah tanaman sedang perlu disiram?'], 
                        menus(List), nl, read(Pilihan), write("<< ---------------------------------------- >>").

% sebagai inputan user (cukup ketik go. pada terminal dan semua rule di atas akan dijalankan)
go :- input_menu(Pilihan, List).
menu1 :- input_container(VolumeContainer), input_vol_1_irigasi(Volume1Irigasi), input_jlh_irigasi(JumlahIrigasi), 
                        cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, 0, VolumeContainer, _).