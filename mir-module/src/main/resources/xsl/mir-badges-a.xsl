<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges:mir-badges-a.xsl"/>

  <xsl:template match="doc" mode="resultList">
    <h5>
      <xsl:value-of select="concat('mir-badges-a.xsl => ',str[@name='id'])"/>
    </h5>
    <xsl:apply-imports/>
  </xsl:template>
</xsl:stylesheet>
