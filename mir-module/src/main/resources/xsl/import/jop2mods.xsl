<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods">

  <xsl:template match="/OpenURLResponseXML">
    <mods:mods>
      <xsl:apply-templates select="Full/PrintData/ResultList/Result[1]/Title" />
      <xsl:apply-templates select="Full/ElectronicData[not(../PrintData)]/ResultList/Result[1]/Title" />
      <xsl:if test="Full/PrintData/ResultList/Result/Signature">
        <mods:location>
          <xsl:apply-templates select="Full/PrintData/ResultList/Result[Signature][1]/Signature" />
        </mods:location>
      </xsl:if>
    </mods:mods>
  </xsl:template>

  <xsl:template match="PrintData/ResultList/Result">
    <xsl:apply-templates select="Title" />
    <xsl:apply-templates select="Signature" />
  </xsl:template>

  <xsl:template match="Title">
    <mods:titleInfo>
      <mods:title>
        <xsl:value-of select="text()" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="Signature">
    <mods:shelfLocator>
      <xsl:choose>
        <xsl:when test="starts-with(.,'E ')">
          <xsl:value-of select="concat('E',substring-after(.,' '))" />
        </xsl:when>
        <xsl:when test="starts-with(.,'D ')">
          <xsl:value-of select="concat('D',substring-after(.,' '))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="text()" />
        </xsl:otherwise>
      </xsl:choose>
    </mods:shelfLocator>
  </xsl:template>

</xsl:stylesheet>