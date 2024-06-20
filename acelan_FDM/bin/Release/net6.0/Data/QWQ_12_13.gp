set terminal png 
set output 'Data\Maps_2024_06_20T22_02_15.png' 
set xlabel 'X(m)'
set ylabel 'Y'
set xrange [1:143]
set yrange [1:97]
set zrange [-1.06:16.0] noreverse nowriteback 
set palette defined ( 0 '#19d024' ,  0 '#19d024',  0 '#11cc6d',  1 '#00b7ff',  2 '#00a1ff',  4 '#007cff',  6 '#0057ff',  8 '#0033ff', 10 '#000eff', 12 '#1300ff', 14 '#4400ff', 16 '#7500ff', 18 '#9c00ff', 20 '#c400ff', 22 '#ff00ff', 24 '#ff00e1', 26 '#ff00c4', 28 '#ff0099', 30 '#ff007f', 32 '#ff005e', 34 '#ff0033', 36 '#ff0015', 38 '#f70000', 40 '#dd0000', 42 '#d20000', 44 '#bf0000', 46 '#ac0000', 48 '#9d0000', 50 '#8e0000', 52 '#870000', 54 '#6a0000', 56 '#530000', 58 '#380000', 60 '#160000', 62 'black')
set view map
unset surface
set pm3d implicit at b
set cbrange [-0.99:50]
splot 'Data\S_K_55_65_100_Out007_2024_06_20T22_02_15.res'
