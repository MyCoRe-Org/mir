<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <options>
      <xsl:apply-templates />
    </options>
  </xsl:template>

  <xsl:template match="db">
    <option value="{driver}">
      <xsl:value-of select="@name" />
    </option>
  </xsl:template>
</xsl:stylesheet>