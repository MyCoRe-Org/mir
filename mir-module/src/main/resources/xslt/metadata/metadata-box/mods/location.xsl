<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='location.url']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:for-each select="$mods/mods:location/mods:url">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="
          if (@access) then concat('component.mods.metaData.dictionary.url.', replace(@access, ' ', '_'))
          else 'component.mods.metaData.dictionary.url'
        " />
        <xsl:with-param name="value">
          <xsl:call-template name="location-url">
            <xsl:with-param name="url" select="." />
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="field[@name='location.physical']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.physicalLocation'" />
      <xsl:with-param name="nodes" select="$mods/mods:location/mods:physicalLocation[not(starts-with(@xlink:href, '#'))]" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="field[@name='location.shelf']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="label-key" select="'mir.shelfmark'" />
      <xsl:with-param name="nodes" select="$mods/mods:location/mods:shelfLocator" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="location-url">
    <xsl:param name="url" as="element(mods:url)" />

    <a href="{$url}">
      <xsl:choose>
        <xsl:when test="string-length(@displayLabel) &gt; 0">
          <xsl:value-of select="@displayLabel" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

</xsl:stylesheet>
