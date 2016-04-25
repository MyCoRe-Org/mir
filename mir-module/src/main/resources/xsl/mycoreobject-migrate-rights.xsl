<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="mods xlink">
  <xsl:include href="copynodes.xsl" />

  <xsl:template match="//mods:mods/mods:accessCondition[@type='use and reproduction']">
    <mods:accessCondition type="use and reproduction">
      <xsl:attribute name="xlink:href">
        <xsl:choose>
          <xsl:when test="@xlink:href">
            <xsl:choose>
              <xsl:when test="contains(@xlink:href, 'http://www.mycore.org/classifications/mir_rights#')">
                <xsl:value-of select="'http://www.mycore.org/classifications/mir_licenses#'" />
                <xsl:value-of select="substring-after(@xlink:href,'#')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@xlink:href" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="contains(., 'cc_')">
            <xsl:value-of select="concat('http://www.mycore.org/classifications/mir_licenses#',.,'_3.0')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('http://www.mycore.org/classifications/mir_licenses#',.)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </mods:accessCondition>
  </xsl:template>
</xsl:stylesheet>