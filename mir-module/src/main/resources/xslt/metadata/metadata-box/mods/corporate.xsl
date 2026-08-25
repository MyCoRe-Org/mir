<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.w3.org/2005/xquery-local-functions"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/corporate.xsl" />
  <xsl:import href="resource:xslt/metadata/common/metadata-row.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/name.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:variable name="institutes-uri" select="
      document('classification:metadata:-1:children:mir_institutes')/mycoreclass/label[@xml:lang='x-uri']/@text
    " />
    <xsl:variable name="corporate" select="
      metadata/def.modsContainer/modsContainer/mods:mods/mods:name[@type='corporate'][not(@ID)][@authorityURI=$institutes-uri]
    " />

    <xsl:for-each select="$corporate">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="local:corporate-label-key(.)" />
        <xsl:with-param name="value">
          <xsl:apply-templates select="." mode="name" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="local:corporate-label-key" as="xs:string">
    <xsl:param name="corporate" as="element(mods:name)" />

    <xsl:variable name="role-code" select="
      $corporate/mods:role/mods:roleTerm[@type='code' and @authority='marcrelator'][1]
    " />

    <xsl:choose>
      <xsl:when test="$role-code">
        <xsl:sequence select="'component.mods.metaData.dictionary.institution.' || $role-code || '.label'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'component.mods.metaData.dictionary.institution.label'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
