<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mirrelateditemfinder="xalan://org.mycore.mir.impexp.MIRRelatedItemFinder"
                xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="xlink mirrelateditemfinder">
  <xsl:param name="MIR.projectid.default"/>
  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:relatedItem[not(@xlink:href)]">
    <xsl:choose>
      <xsl:when test="mods:titleInfo/mods:title or mods:identifier">
        <xsl:variable name="mcrid" select="mirrelateditemfinder:findRelatedItem(node())"/>
        <xsl:choose>
          <xsl:when test="string-length($mcrid) &gt; 0">
            <xsl:copy>
              <xsl:attribute name="xlink:href"><xsl:value-of select="$mcrid"/></xsl:attribute>
              <xsl:apply-templates select="@*|node()" />
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:attribute name="xlink:href"><xsl:value-of select="concat($MIR.projectid.default,'_mods_00000000')"/></xsl:attribute>
              <xsl:apply-templates select="@*|node()" />
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>