<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="dbtypes" select="document('resource:setup/dbtypes.xml')" />

  <xsl:template match="wizard">
    <wizard>
      <xsl:apply-templates select="@*|*" />
    </wizard>
  </xsl:template>

  <xsl:template match="database">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:copy-of select="$dbtypes//db[driver = current()/driver]/library" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>