<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.mycore.de/xslt/mirlocal/metadata-box/mods/related-item"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='related-item']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:for-each select="$mods/mods:relatedItem[not(@type='host' and @xlink:href)]">
      <xsl:choose>
        <xsl:when test="@xlink:href">
          <xsl:call-template name="related-item-row">
            <xsl:with-param name="parentID" select="@xlink:href" />
            <xsl:with-param name="label" select="local:related-item-label(.)" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="related-item-row">
            <xsl:with-param name="parentID" select="''" />
            <xsl:with-param name="label" select="local:related-item-label(.)" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="field[@name='related-item.volume']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="nodes" select="$mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']/mods:number" />
      <xsl:with-param name="label" select="mcri18n:translate('component.mods.metaData.dictionary.volume.article')" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="field[@name='related-item.issue']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="nodes" select="$mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number" />
      <xsl:with-param name="label" select="mcri18n:translate('mir.details.issue')" />
    </xsl:call-template>
  </xsl:template>

  <xsl:function name="local:related-item-label" as="xs:string">
    <xsl:param name="element" as="element(mods:relatedItem)" />

    <xsl:choose>
      <xsl:when test="$element/@displayLabel">
        <xsl:sequence select="$element/@displayLabel" />
      </xsl:when>
      <xsl:when test="$element/@type">
        <xsl:sequence select="mcri18n:translate('mir.relatedItem.' || $element/@type)" />
      </xsl:when>
      <xsl:when test="$element/@otherType">
        <xsl:sequence select="mcri18n:translate('mir.relatedItem.' || $element/@otherType)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="mcri18n:translate('mir.relatedItem')" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
