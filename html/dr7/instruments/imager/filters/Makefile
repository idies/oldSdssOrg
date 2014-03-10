u.html : u.dat
	awk -f buildHtmlTable.awk u.dat > u.html

g.html : g.dat
	awk -f buildHtmlTable.awk g.dat > g.html

r.html : r.dat
	awk -f buildHtmlTable.awk r.dat > r.html

i.html : i.dat
	awk -f buildHtmlTable.awk i.dat > i.html

z.html : z.dat
	awk -f buildHtmlTable.awk z.dat > z.html

index.html : top.html u.html g.html r.html i.html z.html bottom.html
	cat top.html u.html g.html r.html i.html z.html bottom.html > index.html
u_respt.dat: u.dat
	 awk '{print $$1, $$2}' u.dat > u_respt.dat

g_respt.dat: g.dat
	 awk '{print $$1, $$2}' g.dat > g_respt.dat

r_respt.dat: r.dat
	 awk '{print $$1, $$2}' r.dat > r_respt.dat

i_respt.dat: i.dat
	 awk '{print $$1, $$2}' i.dat > i_respt.dat

z_respt.dat: z.dat
	 awk '{print $$1, $$2}' z.dat > z_respt.dat

u_resna.dat: u.dat
	 awk '{print $$1, $$4}' u.dat > u_resna.dat

g_resna.dat: g.dat
	 awk '{print $$1, $$4}' g.dat > g_resna.dat

r_resna.dat: r.dat
	 awk '{print $$1, $$4}' r.dat > r_resna.dat

i_resna.dat: i.dat
	 awk '{print $$1, $$4}' i.dat > i_resna.dat

z_resna.dat: z.dat
	 awk '{print $$1, $$4}' z.dat > z_resna.dat

filterCurves.graph: u_respt.dat g_respt.dat r_respt.dat i_respt.dat z_respt.dat u_resna.dat g_resna.dat r_resna.dat i_resna.dat z_resna.dat
	 graph \
	 --x-label "wavelength" \
	 --y-label "Q. E." \
	 --x-limits 2980 11230 \
	 --y-limits 0 0.6 \
	 --toggle-use-color \
	 --line-mode 3 \
	 u_respt.dat \
	 --line-mode 2 \
	 g_respt.dat \
	 --line-mode 1 \
	 r_respt.dat \
	 --line-mode 4 \
	 i_respt.dat \
	 --toggle-use-color \
	 --line-mode 1 \
	 z_respt.dat \
	 --toggle-use-color \
	 --line-mode 23 \
	 u_resna.dat \
	 --line-mode 22 \
	 g_resna.dat \
	 --line-mode 21 \
	 r_resna.dat \
	 --line-mode 24 \
	i_resna.dat \
	--toggle-use-color \
	--line-mode 4 \
	z_resna.dat \
	> filterCurves.graph

X: filterCurves.graph
	plot -T 'X' filterCurves.graph

filterCurves.ps: filterCurves.graph
	plot -T 'ps' filterCurves.graph

filterCurves.png: filterCurves.graph
	plot -T 'png' filterCurves.graph > filterCurves.png

