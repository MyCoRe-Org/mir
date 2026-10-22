<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='parent']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:for-each select="$object[structure/parents/parent/@xlink:href]">
      <xsl:call-template name="related-item-by-id">
        <xsl:with-param name="parentID" select="structure/parents/parent/@xlink:href" />
        <xsl:with-param name="label" select="mcri18n:translate('component.mods.metaData.dictionary.confpubIn')" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
