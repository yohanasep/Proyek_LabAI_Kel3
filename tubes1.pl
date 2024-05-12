:- discontiguous check/1.

% apakah tanaman perlu disiram?
pump_on :- tanaman_perlu_disiram, write(pump_on), write(water_menyerap), sleep(5), pump_on.
pump_off :- tanaman_tidak_perlu_disiram.

tanaman_perlu_disiram :- tanah_kering.
tanaman_tidak_perlu_disiram :- tanah_lembab.

% jenis irigasi apa yang cocok digunakan
:- op(800, xfx, jenis_penyiraman).
cabai jenis_penyiraman sprinkle.
kol jenis_penyiraman drip.

% informasi assertion
condition([]) :- !.
condition([Head | Tail]) :- write(Head), nl, condition(Tail).
print_condition :- write("<< Assertion menu >>"), List = ['tanah_kering', 'tanah_lembab', 'curah_hujan_tinggi',
                        'curah_hujan_rendah'], nl, condition(List).

% cek apakah air di container cukup untuk mengairi lahan
:- dynamic input_container/1.
:- dynamic input_vol_1_irigasi/1.
:- dynamic input_jlh_irigasi/1.

check(input_container(VolumeContainer)) :- input_container(VolumeContainer).
check(input_1_irigasi(Volume1Irigasi)) :- input_1_irigasi(Volume1Irigasi).
check(input_jlh_irigasi(JumlahIrigasi)) :- input_jlh_irigasi(JumlahIrigasi).

rule_cek_kecukupan_air(_, JumlahIrigasi, JumlahIrigasi, _, Hasil) :- !, Hasil='Cukup', write(Hasil).

rule_cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, _, VolumeContainer, Hasil) :-
                        VolumeContainer < Volume1Irigasi, JumlahIrigasi =\= 0, !,
                        Hasil='Tidak Cukup', write(Hasil).

rule_cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, JumlahIrigasi1, VolumeContainer, Hasil) :-
                        VolumeContainer >= Volume1Irigasi,
                        SisaAir is VolumeContainer - Volume1Irigasi,
                        IrigasiYangSudahDiAiri is JumlahIrigasi1 + 1,
                        rule_cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, IrigasiYangSudahDiAiri, SisaAir, Hasil).

cek_kecukupan_air :- input_container(VolumeContainer), input_1_irigasi(Volume1Irigasi), input_jlh_irigasi(JumlahIrigasi),
                        rule_cek_kecukupan_air(Volume1Irigasi, JumlahIrigasi, 0, VolumeContainer, _).

% berapa banyak air yang dibutuhkan
:- op(200, xf, pilihanTumbuhan).
cabai pilihanTumbuhan.
kol pilihanTumbuhan.

pilihanTumbuhan(tumbuhanTerpilih) :- read(tumbuhanTerpilih), assert(pilihanTumbuhan(tumbuhanTerpilih)).

:-dynamic input_suhu/1.
:-dynamic input_kelembaban/1.
:-dynamic input_pH_tanah/1.

check(pilihanTumbuhan(TumbuhanTerpilih)) :- pilihanTumbuhan(TumbuhanTerpilih).
check(input_suhu(Suhu)) :- input_suhu(Suhu).
check(input_kelembaban(Kelembaban)) :- input_kelembaban(Kelembaban).
check(input_pH_tanah(pH_tanah)) :- input_pH_tanah(pH_tanah).

tingkat_kebutuhan_air(Suhu, Kelembaban, Ph_tanah, KebutuhanAir) :-
                        (Suhu > 35 -> SkorSuhu is 3;
                        (Suhu >= 25, Suhu =< 35) -> SkorSuhu is 2;
                        Suhu < 25 -> SkorSuhu is 1),
                        (Kelembaban > 75 -> SkorKelembaban is 3;
                        (Kelembaban >= 50, Kelembaban =< 75) -> SkorKelembaban is 2;
                        Kelembaban < 50 -> SkorKelembaban is 1),
                        (Ph_tanah > 7 -> SkorPh_tanah is 3;
                        (Ph_tanah >= 6, Ph_tanah =< 7) -> SkorPh_tanah is 2;
                        Ph_tanah < 6 -> SkorPh_tanah is 1),
                        TotalScore is SkorSuhu + SkorKelembaban + SkorPh_tanah,
                        (TotalScore >= 12 -> KebutuhanAir = 'high';
                        (TotalScore >= 8, TotalScore < 12) -> KebutuhanAir = 'middle';
                        TotalScore < 8 -> KebutuhanAir = 'low').

jumlah_air_diperlukan('low', 2).
jumlah_air_diperlukan('middle', 5).
jumlah_air_diperlukan('high', 10).

cek_banyak_air_diperlukan :- 
                        input_suhu(Suhu), input_kelembaban(Kelembaban), input_pH_tanah(Ph_tanah),
                        tingkat_kebutuhan_air(Suhu, Kelembaban, Ph_tanah, KebutuhanAir), jumlah_air_diperlukan(KebutuhanAir, JumlahAir),
                        format('Tingkat kebutuhan air anda adalah ~w, dan banyak air yang diperlukan adalah ~w liter.~n', [KebutuhanAir, JumlahAir]).