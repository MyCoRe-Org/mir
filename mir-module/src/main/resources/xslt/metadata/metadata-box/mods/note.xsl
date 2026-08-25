<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.w3.org/2005/xquery-local-functions"
  xmlns:mcrclass="http://www.mycore.de/xslt/classification"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/note.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods/mods:note">
      <xsl:choose>
        <xsl:when test="@type">
          <xsl:variable name="category" select="mcrclass:category('noteTypes', local:sanitize-note-type(@type))" />
          <xsl:if test="contains($category/label[@xml:lang='x-access']/@text, 'guest')">
            <xsl:call-template name="meta-row-from-nodes">
              <xsl:with-param name="nodes" select="." />
              <xsl:with-param name="label" select="mcrclass:current-label-text($category)" />
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="meta-row-from-nodes">
            <xsl:with-param name="nodes" select="." />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="local:sanitize-note-type" as="xs:string">
    <xsl:param name="type" as="xs:string" />
    <xsl:sequence select="replace(normalize-space($type), ' ', '_')" />
  </xsl:function>

</xsl:stylesheet>
