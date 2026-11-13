# Faza 1 - Porazdelitev temperature v 2D prerezu

Prva faza projektne naloge pri predmetu Napredna računalniška orodja (UL FS). Program rešuje stacionarni prevod toplote v prerezu turbinske lopatice z osmimi hladilnimi kanali. Uporablja kvadratne celice, konstantno prevodnost in model brez notranjih virov. Koordinate so v metrih, temperature v °C. Izris prikazuje koordinate v mm.

## Zagon

V MATLAB-u odprite mapo `faze/faza1` in izvedite naslednji ukaz.

```matlab
run('matlab/main.m')
```

Program najprej preveri zgled, nato po vrsti obdela štiri mreže. Nov zagon obnovi dnevnik in rezultate za izvedene korake. Pri primerjavi rezultatov iz več zagonov upoštevajte dnevnik zadnjega zagona.

## Projektne mape

| Mapa | Vsebina |
|---|---|
| `dokumentacija/gradiva/faza1/navodila` | Uradna navodila, zlasti tabela 1, enačba (9), tabeli 2 in 3 ter razdelek 4 |
| `vhodni_podatki` | Predloga in štiri gostote mreže iste lopatice |
| `dokumentacija/gradiva/faza1/vaje` | Gradiva vaj s primeri kode in navodili |
| `matlab` | Skripta in funkcije |
| `rezultati/grafi` | `lopatica_mreza.png`, osnovna mreža in štiri skupine robnih pogojev, 300 dpi |
| `rezultati/binarne_datoteke` | Par datotek za vsakega od petih vhodov. Predpona je ime vhodne datoteke brez končnice. |
| `rezultati/izpisi` | Datoteke `*_T.mat` za rešene primere. Vsebujejo stolpec `T` v zaporedju ID, `dx`, `k` in neskalirano neskončno normo ostanka. |
| `rezultati/testi` | `povzetek.txt` z rezultati preverjanj, energijsko bilanco in odločitvijo o direktni rešitvi |
| `porocilo` | Končni PDF, LaTeX izvorne datoteke in arhiv poročila |

## Program in diskretizacija

| Datoteka | Naloga |
|---|---|
| main.m | Vodi obdelavo, določi k, zažene preverjanja, izračuna kontrolne temperature in bilanco ter shrani rezultate. |
| preberiMrezo.m | S funkcijami fopen, fgetl in fscanf prebere koordinate, povezljivost in skupine. Preveri ID-je, razvrsti zapise ter pretvori indekse na osnovo 1. |
| najdiSosede.m | Izmeri dx iz celic, s toleranco 10⁻⁶ dx preveri vse štiri vogale in sestavi redko matriko števila celic ob vsaki povezavi. |
| razvrstiVozlisca.m | Prešteje celice in sosede, preveri tip vozlišča in popolnost oznak roba. |
| sestaviSistem.m | Iz matrike povezav in robnih podatkov sestavi redko A ter stolpec b. |
| izvediPreverjanja.m | Primerja celotna A in b z enačbo (9) in direktno rešitev z uradnimi zaokroženimi temperaturami. Posebej preveri gostoto toka na ravnem robu in zunanjem kotu. |
| narisiMrezo.m | Iz povezljivosti nariše vse celice, iz vozlišč skupin pa zunanje robne pogoje in stene kanalov. |
| izvoziSistem.m, uvoziSistem.m | Pretvorita med MATLAB-ovo redko matriko in binarnim CSR. |
| izvoziGeometrijo.m | Zapiše in ponovno preveri koordinate in povezljivost. |

Za notranje vozlišče ima vsak od štirih sosedov koeficient 1, diagonala je −4 in desna stran 0. Na robu predstavlja koeficient soseda število celic ob skupni stranici (1 ali 2). Vsota sosednjih koeficientov S je 2 za zunanji kot, 4 za raven rob in 6 za notranji kot. Tako se pri zasuku geometrije uteži samodejno premaknejo k pravim sosedom. Podvojen ali manjkajoč robni pogoj prekine obdelavo.

| Robni pogoj | Diagonala | Desna stran |
|---|---:|---:|
| Predpisana temperatura | 1, drugi koeficienti so 0 | Tᵣₚ |
| Tok q, pozitiven v telo | −S | −2q Δx/k |
| Prestop, Bi = h Δx/k | −S − 2Bi | −2Bi T∞ |

## Preverjeni rezultati

Vhodom v tabeli pripada končnica .txt. Zgled uporablja k = 1 W/(m K) in dx = 1 m. Vse mreže lopatice uporabljajo k = 22 W/(m K).

| Vhod | Vozlišča | Celice | dx [mm] | nnz(A) | T min–max [°C] |
|---|---:|---:|---:|---:|---|
| primer_predloga_projekt | 16 | 9 | 1000 | 38 | 50–300 |
| lopatica_mreza | 5.152 | 4.763 | 0,25 | 24.996 | 641,975–1127,071 |
| lopatica_mreza_r1 | 19.837 | 19.052 | 0,125 | 97.629 | 641,051–1128,643 |
| lopatica_mreza_r2 | 77.785 | 76.208 | 0,0625 | 385.785 | 640,702–1129,380 |
| lopatica_mreza_r3 | 307.993 | 304.832 | 0,03125 | 1.533.657 | Direktna rešitev preskočena |

V MATLAB-u se vseh 256 koeficientov A in vseh 16 vrednosti b za zgled ujema natančno. Največja absolutna razlika v T je 4,25521·10⁻⁵ °C ob toleranci 5,0001·10⁻⁵ °C (referenca na štiri decimalke). Pri vseh petih primerih so prestale preverjanje dimenzije, topologija, pokritost roba, diagonala, število neničelnih vrednosti, končnost in binarna povratna primerjava.

Za rešene mreže lopatice so vse temperature med 450 in 1200 °C. Osnovna mreža ima na zunanjem robu povprečno 920,272 °C, na stenah kanalov 726,416 °C. Prispevek skupine k toplotnemu toku na enoto dolžine je vsota h Δx (T∞ − Tᵢ) po njenih vozliščih. Vsakemu pripadata dve polovici izpostavljene stranice, tudi v kotih. Absolutna vsota vseh štirih prispevkov, deljena z vsoto njihovih absolutnih vrednosti, je na treh rešenih mrežah manjša od 3·10⁻¹⁴. To preverja diskretno energijsko bilanco. Uradne referenčne temperature za lopatico niso podane.

Pri več kot 100.000 vozliščih `main.m` na Windows preveri prost fizični RAM pred direktnim reševanjem. Za ocenjeni delovni prostor uporablja konservativen prag 8192 bajtov na vozlišče. Pri r3 je bilo prostih 2,30 GiB ob pragu 2,35 GiB. Sistem in geometrija sta bila zapisana ter preverjena. Ob zagonu z več prostega pomnilnika lahko isti program izračuna tudi r3. Na drugih platformah pri toliko vozliščih samodejno preskoči direktno rešitev.

## Binarni format za naslednjo fazo

Vse datoteke uporabljajo little-endian, brez dopolnilnih bajtov, besedila ali oznak med polji. Realna števila so IEEE 754 binary64. Vsaka tabela spodaj predstavlja natančen vrstni red polj od začetka datoteke.

| *_sistem.bin | Tip | Število elementov | Pomen |
|---|---|---:|---|
| N | uint64 | 1 | Dimenzija kvadratnega sistema |
| nnz | uint64 | 1 | Število neničelnih koeficientov |
| row_ptr | uint64 | N+1 | Odmiki v elementih, prvi 0, zadnji nnz |
| col_idx | uint32 | nnz | Indeks stolpca od 0, strogo naraščajoč znotraj vrstice |
| values | binary64 | nnz | Koeficienti v vrstnem redu col_idx |
| b | binary64 | N | Desna stran v zaporedju ID |

Za vrstico i (od 0) uporabimo indekse od row_ptr[i] do izključno row_ptr[i+1]. MATLAB-ov find na transponirani A vrne elemente v tem vrstnem redu. Dolžina datoteke je 24 + 16N + 12nnz bajtov. Uvoz preveri dolžino, odmike, urejenost, območje stolpcev in numerične vrednosti. Glavni program zahteva natančno enakost rekonstruiranih A in b z izvirnikoma.

| *_geom.bin | Tip | Število elementov | Pomen |
|---|---|---:|---|
| N, M | uint64 | 2 | Število vozlišč in celic |
| Koordinate | binary64 | 2N | x₀, y₀, x₁, y₁, … v metrih |
| Povezljivost | uint32 | 4M | Po štirje ID-ji od 0 za vsako celico v zaporedju zgoraj levo, spodaj levo, spodaj desno, zgoraj desno |

Geometrija ima 16 + 16N + 16M bajtov. Povratni test primerja obe dimenziji, vse koordinate, vse štiri indekse vsake celice in konec datoteke.
"# projektna-naloga" 
