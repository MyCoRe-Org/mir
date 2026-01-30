<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="//mods:name[@type='conference']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="node()[not(self::mods:displayForm)]" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
