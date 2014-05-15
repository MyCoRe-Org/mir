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
    <xsl:for-each select="*">
      <doc>
        <xsl:apply-templates select=".">
          <xsl:with-param name="foo" select="$foo" />
        </xsl:apply-templates>
      </doc>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/*[local-name()!='add']" mode="doc">
    <xsl:param name="foo" />
    <!-- single doc processing -->
    <doc>
      <xsl:apply-templates select=".">
        <xsl:with-param name="foo" select="$foo" />
      </xsl:apply-templates>
    </doc>
  </xsl:template>

</xsl:stylesheet>
