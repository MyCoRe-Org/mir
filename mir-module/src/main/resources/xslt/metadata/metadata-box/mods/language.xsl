<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='language']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:for-each select="$mods/mods:language">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.language'" />
        <xsl:with-param name="value">
          <xsl:call-template name="joined-values">
            <xsl:with-param name="nodes" select="mods:languageTerm[@authority='rfc5646']" />
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:languageTerm[@authority='rfc5646']" mode="value-content">
    <xsl:apply-templates select="." mode="classification" />
  </xsl:template>

  <xsl:template match="mods:languageTerm[@authority='rfc5646']" mode="value-suffix">
    <meta property="inLanguage" content="{.}" />
  </xsl:template>

</xsl:stylesheet>
