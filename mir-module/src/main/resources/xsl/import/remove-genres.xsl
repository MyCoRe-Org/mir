<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mods xsl">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:genre" />
    
  <xsl:template match="mods:identifier[@type='isbn']" >
    <xsl:variable name="isbn" select="translate(text(),'-','')" />
    <xsl:variable name="valid_isbn">
      <xsl:choose>
        <xsl:when test="translate($isbn,'123456789X','0000000000') = '0000000000000' and (starts-with($isbn,'978') or starts-with($isbn,'979')) ">
          <xsl:value-of select="text()" />
        </xsl:when>
        <xsl:when test="translate($isbn,'123456789X','0000000000') = '0000000000' ">
          <xsl:value-of select="text()" />
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length($valid_isbn) &gt; 0">
      <mods:identifier type="isbn">
        <xsl:value-of select="text()" />
      </mods:identifier>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:relatedItem/@otherType[../@type]">
    <!-- MIR-1120 remove @otherType if @type is present -->
  </xsl:template>

</xsl:stylesheet>
