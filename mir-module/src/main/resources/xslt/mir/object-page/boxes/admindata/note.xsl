<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirnotes="http://www.mycore.de/xslt/mirnotes"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='note']" mode="admindata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:for-each select="$mods/mods:note[mirnotes:visible(., ('editor', 'admin'))]">
      <xsl:variable name="label" select="mirnotes:label(.)" />
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label" select="if ($label) then $label else mirnotes:type(.)" />
        <xsl:with-param name="value">
          <xsl:call-template name="lf2br">
            <xsl:with-param name="string" select="." />
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
