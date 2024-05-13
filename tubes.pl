:- discontiguous check_if_exist/1.

% informasi assertion
kondisi([]) :- !.
kondisi([Head | Tail]) :- write(Head), nl, kondisi(Tail).
print_kondisi :- write("<< Assertion menu >>"), List = ['1. tanah_kering/0', '2. tanah_lembab/0', '3. input_vol_container/1', 
                        '4. input_vol_1_irigasi/1', '5. input_jlh_irigasi/1', '6. input_suhu/1' , '7. input_kelembaban/1',
                        '8. input_pH_tanah/1'], nl, kondisi(List).

% apakah tanaman perlu disiram?
tanaman_perlu_disiram :- tanah_kering.
tanaman_tidak_perlu_disiram :- not(tanah_kering).

cek_kondisi_tanah(Kondisi) :- retract(tanah_kering), read(Kondisi), assert(Kondisi), 
                        (tanaman_perlu_disiram -> pump_on ; pump_off).

pump_on :- write(pump_on), nl, sleep(2), cek_kondisi_tanah(_).
pump_off.

action :- (tanaman_perlu_disiram -> pump_on ; fail).

% jenis irigasi apa yang cocok digunakan
:- op(200, xf, pilihanTumbuhan).
cabai pilihanTumbuhan.
kol pilihanTumbuhan.

:- op(800, xfx, jenis_penyiraman).
cabai jenis_penyiraman sprinkle.
kol jenis_penyiraman drip.

tentukan_jenis_penyiraman :- write("Tumbuhan: "), read(TumbuhanTerpilih), 
                        (pilihanTumbuhan(TumbuhanTerpilih) -> 
                        TumbuhanTerpilih jenis_penyiraman Apa, format('Jenis penyiraman: ~w.~n', [Apa]) ;
                        fail).

% cek apakah air di container cukup untuk mengairi lahan
:- dynamic input_vol_container/1.
:- dynamic input_vol_1_irigasi/1.
:- dynamic input_jlh_irigasi/1.

check_if_exist(input_vol_container) :- input_vol_container(_).
check_if_exist(input_vol_1_irigasi) :- input_vol_1_irigasi(_).
check_if_exist(input_jlh_irigasi) :- input_jlh_irigasi(_).

% base case
rule_cek_kecukupan_air(_, JumlahIrigasi, JumlahIrigasi, _, Hasil) :- !, Hasil='Cukup', write(Hasil).

% base case
rule_cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, _, VolumeContainer, Hasil) :- 
                        VolumeContainer < Volume1Irigasi, JumlahIrigasi =\= 0, !, 
                        Hasil='Tidak Cukup', write(Hasil).

rule_cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, JumlahIrigasi1, VolumeContainer, Hasil) :- 
                        VolumeContainer >= Volume1Irigasi,
                        SisaAir is VolumeContainer - Volume1Irigasi,
                        IrigasiYangSudahDiAiri is JumlahIrigasi1 + 1,
                        rule_cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, IrigasiYangSudahDiAiri, SisaAir, Hasil).

cek_kecukupan_air :- input_vol_container(VolumeContainer), input_vol_1_irigasi(Volume1Irigasi), input_jlh_irigasi(JumlahIrigasi),
                        rule_cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, 0, VolumeContainer, _).

% berapa banyak air yang dibutuhkan
:-dynamic input_suhu/1.
:-dynamic input_kelembaban/1.
:-dynamic input_pH_tanah/1.

check_if_exist(input_suhu) :- input_suhu(_).
check_if_exist(input_kelembaban) :- input_kelembaban(_).
check_if_exist(input_pH_tanah) :- input_pH_tanah(_).

tingkat_kebutuhan_air(Suhu, Kelembaban, Ph_tanah, KebutuhanAir) :-
                    (Suhu > 35 -> SkorSuhu is 3;
                    (Suhu >= 25, Suhu =< 35) -> SkorSuhu is 2;
                    Suhu < 25 -> SkorSuhu is 1),
                    (Kelembaban > 75 -> SkorKelembaban is 3;
                    (Kelembaban >= 50, Kelembaban =< 75) -> SkorKelembaban is 2; 
                    Kelembaban < 50 -> SkorKelembaban is 1), 
                    (Ph_tanah > 6.5 -> Skor_pH_tanah is 3; 
                    (Ph_tanah >= 6.0, Ph_tanah =< 6.5) -> Skor_pH_tanah is 2; 
                    Ph_tanah < 6.0 -> Skor_pH_tanah is 1),
                    TotalScore is SkorSuhu + SkorKelembaban + Skor_pH_tanah,
                    (TotalScore >= 12 -> KebutuhanAir = 'high';
                    (TotalScore >= 8, TotalScore < 12) -> KebutuhanAir = 'mid';
                    TotalScore < 8 -> KebutuhanAir = 'low').

jumlah_air_diperlukan(KebutuhanAir, JumlahAir) :- (KebutuhanAir = 'low' -> Val is 1500 ;
                    KebutuhanAir = 'mid' -> Val is 1500 ;
                    KebutuhanAir = 'high' -> Val is 4000), 
                    (not(check_if_exist(input_vol_1_irigasi)) -> Volume1Irigasi is 1 ; input_vol_1_irigasi(Volume1Irigasi)),
                    (not(check_if_exist(input_jlh_irigasi)) -> JumlahIrigasi is 1 ; input_jlh_irigasi(JumlahIrigasi)),
                    JumlahAir is Val * Volume1Irigasi * JumlahIrigasi.

cek_banyak_air_diperlukan :- 
                    input_suhu(Suhu), input_kelembaban(Kelembaban), input_pH_tanah(Ph_tanah),
                    tingkat_kebutuhan_air(Suhu, Kelembaban, Ph_tanah, KebutuhanAir), jumlah_air_diperlukan(KebutuhanAir, JumlahAir),
                    format('Tingkat kebutuhan air: ~w.~nBanyak air diperlukan: ~w liter.~n', [KebutuhanAir, JumlahAir]), 
                    tentukan_jenis_penyiraman.