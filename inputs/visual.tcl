set psffile [glob ../inputs/*.psf]

mol new {$psffile} type {psf} first 0 last -1 step 1 waitfor 1
display projection Orthographic
mol modcolor 0 0 Structure
mol modstyle 0 0 NewCartoon 0.300000 10.000000 4.100000 0
mol color Structure
mol addfile {coor-prot.dcd} type {dcd} first 0 last -1 step 1 waitfor 1 0
