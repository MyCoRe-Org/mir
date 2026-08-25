<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.mycore.de/mir/xslt/metadata/related-item"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/related-item.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/related-item.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:variable name="related-items" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem" />
    <xsl:for-each select="$related-items[not(@type='host' and @xlink:href)]">
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

    <xsl:variable name="detail" select="$related-items[@type='host']/mods:part/mods:detail" />
    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="nodes" select="$detail[@type='volume']/mods:number" />
      <xsl:with-param name="label" select="mcri18n:translate('component.mods.metaData.dictionary.volume.article')" />
    </xsl:call-template>

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="nodes" select="$detail[@type='issue']/mods:number" />
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
