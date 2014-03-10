NR == 1 {filter = substr(FILENAME,0,1); print "<h2>Sensativity table for the ",filter," filter</h2><table><caption>",filter,"</caption><tbody><tr><td>wavelength</td><td>on the sky sansativity looking through 1.3 airmasses at APO for a point source</td><td>sensativity under these conditions for very large sources (size greater than about 80 pixels) for which the infrared scattering is negligible</td><td>the response of the third column with <em>no</em> atmosphere</td><td>assumed atmospheric transparency at <em>one</em> airmass at APO</td></tr>"}
NF == 5 {print "<tr><td>",$1,"</td><td>",$2,"</td><td>",$3,"</td><td>",$4,"</td><td>",$5,"</td></tr>"}
END {print "  </tbody> </table>"}

