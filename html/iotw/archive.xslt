<?xml version="1.0"?>
<xsl:stylesheet 
               version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xi="http://www.w3.org/2001/XInclude">

  <xsl:output 
	method="html"
	encoding="ISO-8859-1"
	indent="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates select="iotwList"/>
  </xsl:template>

  <xsl:template match="iotwList">
    <xsl:comment>#include virtual="../includes/sdss_page_top.html"</xsl:comment>
    <xsl:comment><xsl:value-of select="instructions"/></xsl:comment>
    <h1>SDSS Image of the Week Archive</h1>
    <p>SDSS images may not be used for any commercial publication or other
    commercial purpose except with explicit approval by the Astrophysical
    Research Consortium(ARC). SDSS images may be downloaded, linked to, or
    otherwise used for non-commercial purposes, provided proper credit is
    given and the use cannot be construed as an endorsement of any product
    or service. For more information on commercial and noncommercial usage,
    please see our <a href="../gallery/usage_policy.html">image use policy</a>.
    </p>
    <p>Unless otherwise noted, images should be credited to the Sloan Digital
    Sky Survey.</p>
    <hr width="80%"/>
    <table>
    <xsl:apply-templates select="iotw"/>
    </table>
    <xsl:comment>#include virtual="../includes/sdss_page_bottom.html"</xsl:comment>
  </xsl:template>

  <xsl:template match="iotw">
    <xsl:param name="thumbnail" select="thumbnail"/>
    <xsl:param name="image" select="image"/>
    <tr>
      <td>
          <a href="{$image}">
            <img src="{$thumbnail}" align="LEFT" hspace="5"/>
          </a>
      </td>
    <td>
       <h2><xsl:value-of select="name"/></h2>
       <xsl:apply-templates select="caption"/>
    </td>
    </tr>
  </xsl:template>

  <xsl:template match="caption">
    <p><xsl:value-of select="."/></p>
  </xsl:template>

</xsl:stylesheet>
