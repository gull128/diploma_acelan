set terminal png 
set output 'Data\Lines_2024_06_20T22_02_15.png' 
set xlabel 'X(m)' 
set ylabel 'Y' 
set xrange [1:143] 
set yrange [1:97] 
set zrange [-1.0:16.0] 
# set style line 
set cntrparam levels disc -0.99, 0.0,     1.00,     1.55,     2.39,     3.71,     5.73,     8.87,    13.73,    21.25,    32.88,    50.87,    78.72,   121.82,   188.51,   291.70 
set nosurface 
set contour base 
set view 0,0 
set key outside
splot 'Data\S_K_55_65_100_Out007_2024_06_20T22_02_15.res' w l ti  'Lines' 
