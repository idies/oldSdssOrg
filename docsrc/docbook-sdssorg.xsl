<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:import href="/usr/share/sgml/docbook/xsl-stylesheets-1.61.2-2/xhtml/docbook.xsl"/>

  <xsl:param name="html.stylesheet">./includes/sdss.css</xsl:param> 

  <xsl:attribute-set name="shade.verbatim.style">
    <xsl:attribute name="border">0</xsl:attribute>
    <xsl:attribute name="bgcolor">#E0E0E0</xsl:attribute>
  </xsl:attribute-set>

<xsl:template name="user.header.content">
    <!-- Apache SSI -->
    <xsl:comment>#include virtual="./includes/sdss_page_top_inner.html"</xsl:comment>
</xsl:template>

<xsl:template name="user.footer.content">
    <!-- Apache SSI -->
    <xsl:comment>#include virtual="./includes/sdss_page_bottom_inner.html"</xsl:comment>
</xsl:template>

</xsl:stylesheet>
