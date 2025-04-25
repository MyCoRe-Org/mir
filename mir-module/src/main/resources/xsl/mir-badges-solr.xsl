<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges"/>

  <xsl:template match="/response">
    <xsl:apply-templates select="result/doc" mode="resultList"/>
  </xsl:template>

  <xsl:template match="doc" mode="resultList">
    <div class="mir-badges">
      <xsl:apply-imports/>
    </div>
  </xsl:template>

</xsl:stylesheet>
