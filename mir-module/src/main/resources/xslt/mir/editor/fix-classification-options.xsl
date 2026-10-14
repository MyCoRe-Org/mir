<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:mode on-no-match="shallow-copy" />

  <xsl:template match="option">
    <xsl:copy>
      <xsl:attribute name="value" select="replace(@value, '_', ' ')" />
      <xsl:apply-templates select="@*[name() != 'value'] | node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
