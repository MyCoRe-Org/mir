<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="*">
  <xsl:element name="{local-name()}">
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<xsl:template match="@*">
  <xsl:attribute name="{local-name()}">
    <xsl:value-of select="." />
  </xsl:attribute>
</xsl:template>

<xsl:template match="text()">
  <xsl:value-of select="." />
</xsl:template>

</xsl:stylesheet>
