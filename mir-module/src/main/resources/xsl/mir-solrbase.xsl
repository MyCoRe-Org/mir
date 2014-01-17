<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:solr-document" />

  <xsl:template match="/">
    <add>
      <xsl:apply-templates mode="doc">
        <xsl:with-param name="foo" select="'bar'" />
      </xsl:apply-templates>
    </add>
  </xsl:template>

  <xsl:template match="/add" mode="doc">
    <xsl:param name="foo" />
    <!-- batch processing -->
    <xsl:apply-templates>
      <xsl:with-param name="foo" select="$foo" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="/*[local-name()!='add']" mode="doc">
    <!-- single doc processing -->
    <doc>
      <xsl:apply-templates select="." />
    </doc>
  </xsl:template>

</xsl:stylesheet>
