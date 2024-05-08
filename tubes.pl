% note: jika ada cara yang lebih efektif yang bisa diperbaiki dari kode2 dibawah boleh sekali di ubah ges, 
% tapi yang kode lama dikomen atau disimpan ya, jgn hapus total. kali aja butuh soalnyaa.

% rule untuk menentukan skala lahan, not very necessary but aint that bad either wkkwkw
skalaContainer(VolumeContainer, Skala) :- (not(number(VolumeContainer)) -> write('Volume container harus dalam bentuk angka!'), fail ;
                                            VolumeContainer < 0 -> write('Volume container tidak boleh bernilai negatif!'), fail ;
                                            VolumeContainer = 0 -> write('Volume container tidak boleh kosong!'), fail ;
                                            VolumeContainer > 0, VolumeContainer =< 50 -> Skala = 'Kecil' ;
                                            VolumeContainer > 50, VolumeContainer =< 500 -> Skala = 'Menegah' ;
                                            Skala = 'Besar').

% input volume container
input_container(VolumeContainer) :- write('Berapa volume container Anda (dalam liter)? '), read(VolumeContainer), 
                                    skalaContainer(VolumeContainer, Skala), write('Container tersebut cocok untuk lahan dengan skala '), write(Skala), nl, nl.

% input volume air yang dibutuhkan untuk 1 saluran irigasi
input_vol_1_irigasi(Volume1Irigasi) :- write('Berapa volume air yang dibutuhkan 1 saluran irigasi Anda (dalam liter)? '), read(Volume1Irigasi), nl.

% input banyaknya total irigasi yang dipunya di lahan itu
input_jlh_irigasi(JumlahIrigasi) :- write('Berapa jumlah total irigasi pada lahan anda? '), read(JumlahIrigasi), nl.

% base case
cek_kecukupan_air(_, JumlahIrigasi, JumlahIrigasi, _, Hasil) :- !, Hasil='Cukup', write(Hasil).

% base case
cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, _, VolumeContainer, Hasil) :- VolumeContainer < Volume1Irigasi, JumlahIrigasi =\= 0, !, Hasil='Tidak Cukup', 
                                                                                write(Hasil).

% Pertama di cek dulu volume di container lebih besar atau sama ga dengan volume yang dibutuhkan untuk 1 saluran irigasi
% Kalo memenuhi, maka untuk saluran irigasi pertama kita isi (dengan mengurangkan volume dalam container sebanyak volume 1 saluran irigasi)
% next hitung berapa irigasi yang sudah di-air-i
% lalu panggil rule nya sendiri (untuk rekursif) dengan parameter yang sudah berubah besarannya
cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, JumlahIrigasi1, VolumeContainer, Hasil) :- VolumeContainer >= Volume1Irigasi,
                                                                        SisaAir is VolumeContainer - Volume1Irigasi,
                                                                        IrigasiYangSudahDiAiri is JumlahIrigasi1 + 1,
                                                                        cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, IrigasiYangSudahDiAiri, SisaAir, Hasil).

% sebagai inputan user (cukup ketik go. pada terminal dan semua rule di atas akan dijalankan)
go :- input_container(VolumeContainer), input_vol_1_irigasi(Volume1Irigasi), input_jlh_irigasi(JumlahIrigasi), cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, 
                                                                                                                                0, VolumeContainer, _).




% rule2 dibawah ini masih coret2 aja, masi error2 jg, kalo mau execute yg atas, yang bawah ini hapus dan simpan aja dlu wkkwkw

% musim :- write('Apakah sekarang sedang musim kemarau (y/n)? '), read(Jawaban),
%          musim(Jawaban, Musim), assert(Musim).

karakteristik(xerofit, ['Hidup di padang gurun', 
                        'Butuh air sedikit', 
                        'Memiliki sistem akar yang dalam untuk menjangkau sumber air yang dalam tanah, atau mereka dapat menyimpan air dalam jaringan mereka sendiri']).

karakteristik(mesofit, ['Hidup di lingkungan yang memiliki kelembapan tanah tingkat sedang', 
                        'Butuh air normal',
                        'Tidak terlalu toleran terhadap kondisi kering atau basah berlebihan']).

karakteristik(higrofit, ['Cenderung tumbuh di lingkungan yang lembab atau basah, seperti rawa-rawa, daerah aliran sungai, atau hutan lembab', 
                        'Butuh air banyak',
                        'Memiliki adaptasi khusus untuk menyesuaikan diri dengan kondisi yang sering kali lembab atau tergenang air']).

karakteristik(halofit, ['Tumbuh di lingkungan yang memiliki kandungan garam tinggi', 
                        'Butuh air banyak',
                        'Memiliki adaptasi untuk bertahan hidup dalam lingkungan yang ekstrem']).

kategori_tumbuhan(xerofit, [kaktus, 'pohon kelapa', 'lidah buaya', 'pohon kurma']).
kategori_tumbuhan(mesofit, [padi, jagung, tomat]).
kategori_tumbuhan(higrofit, [pakis, 'eceng gondok']).
kategori_tumbuhan(halofit, [mangrove, 'rumput pantai']).

informasi_umum(Tumbuhan, Info) :- kategori_tumbuhan(Kategori, ListTumbuhan),
                                  member(Tumbuhan, ListTumbuhan), karakteristik(Kategori, Info).

jenis_penyiraman(Tumbuhan, Skor) :- informasi_umum(Tumbuhan, Info),
                                    (member('Butuh air banyak', Info) ; member('Butuh air normal', Info) -> Skor = 2 ;
                                    member('Butuh air sedikit', Info) -> Skor = 1).

suhu :- (Suhu > 35 -> SkorSuhu is 3;
        (Suhu >= 25, Suhu =< 35) -> SkorSuhu is 2;
        Suhu < 25 -> SkorSuhu is 1).

pH_tanah(Ph, Sifat) :- (Ph > 0, Ph =< 6 -> Sifat = 'Asam' ;
                        Ph == 7 -> Sifat = 'Netral' ;
                        Ph > 7, Ph =< 14 -> Sifat = 'Basa').

kelembapan(NilaiKelembapan, Skor) :- (Kelembapan > 75 -> Skor is 3;
                                     (Kelembapan >= 50, Kelembapan =< 75) -> Skor is 2; 
                                     Kelembapan < 50 -> Skor is 1).

:- op(800, fx, if).
:- op(700, xfx, then).
:- op(200, xfy, and).

if (Skor >= 12) then need_much_water.
if (Skor >= 8, Skor < 12 ) then need_normal_water.
if (Skor < 8) then need_little_water.

% tingkat_kebutuhan_air(Tumbuhan, Suhu, Kelembapan, CurahHujan, PH, KebutuhanAir) :-
%                   (Suhu > 35 -> SkorSuhu is 3;
%                   (Suhu >= 25, Suhu =< 35) -> SkorSuhu is 2;
%                   Suhu < 25 -> SkorSuhu is 1),
%                   (Kelembapan > 75 -> SkorKelembapan is 3;
%                   (Kelembapan >= 50, Kelembapan =< 75) -> SkorKelembapan is 2; 
%                   Kelembapan < 50 -> SkorKelembapan is 1), 
%                   (CurahHujan > 20 -> SkorCurahHujan is 3;
%                   (CurahHujan >= 5, CurahHujan =< 20) -> SkorCurahHujan is 2;
%                   CurahHujan < 5 -> SkorCurahHujan is 1), 
%                   (PH > 6.5 -> SkorPH is 3; 
%                   (PH >= 6.0, PH =< 6.5) -> SkorPH is 2; 
%                   PH < 6.0 -> SkorPH is 1),
%                   TotalScore is SkorSuhu + SkorKelembapan + SkorCurahHujan + SkorPH,
%                   (TotalScore >= 12 -> KebutuhanAir = 'high';
%                   (TotalScore >= 8, TotalScore < 12) -> KebutuhanAir = 'middle';
%                   TotalScore < 8 -> KebutuhanAir = 'low').