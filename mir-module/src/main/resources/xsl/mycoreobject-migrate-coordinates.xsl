<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3">
  <xsl:include href="copynodes.xsl" />
  
  <xsl:template match="//mods:coordinates">
    <xsl:choose>
      <xsl:when test="contains(., '°')">
        <xsl:variable name="lon">
          <xsl:variable name="lon_tmp" select="substring-before(substring-after(., ', '), '°')" />
          <xsl:choose>
            <xsl:when test="contains($lon_tmp, '+')">
              <xsl:value-of select="substring-after($lon_tmp, '+')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$lon_tmp" />
            </xsl:otherwise>          
          </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="lat">
          <xsl:variable name="lat_tmp" select="substring-before(substring-before(., ', '), '°')" />
          <xsl:choose>
            <xsl:when test="contains($lat_tmp, '+')">
              <xsl:value-of select="substring-after($lat_tmp, '+')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$lat_tmp" />
            </xsl:otherwise>          
          </xsl:choose>
        </xsl:variable>
        
        <mods:coordinates>
          <xsl:value-of select="concat($lon, ' ', $lat)" />
        </mods:coordinates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>      
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>