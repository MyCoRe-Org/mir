<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.w3.org/2005/xquery-local-functions"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/name.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/name.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:variable name="names" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:name" />
    <xsl:variable name="institutes-uri" select="
      document('classification:metadata:-1:children:mir_institutes')/mycoreclass/label[@xml:lang = 'x-uri']/@text
    " />
    <xsl:variable name="relevant-names" select="$names[
      not(@ID)
      and (@type = 'personal' or (@type = 'corporate' and not(@authorityURI = $institutes-uri)))
      and not(mods:role/mods:roleTerm = 'aut')
      and mods:role/mods:roleTerm
    ]" />
    <xsl:for-each-group select="$relevant-names" group-by="mods:role/mods:roleTerm">
      <!-- check if 'aut' and 'edt' show 'edt', otherwise 'edt' is already shown in abstract-box -->
      <xsl:if test="not(current-grouping-key() = 'edt' and not($names/mods:role/mods:roleTerm = 'aut'))">
        <xsl:variable name="role-term" select="mods:role/mods:roleTerm" />
        <xsl:call-template name="meta-row">
          <xsl:with-param name="label">
            <xsl:choose>
              <xsl:when test="$role-term[@authority = 'marcrelator' and @type = 'code']">
                <xsl:value-of select="local:role-code-label($role-term[@authority = 'marcrelator' and @type = 'code'][1])" />
              </xsl:when>
              <xsl:when test="$role-term[@authority = 'marcrelator']">
                <xsl:variable name="i18n-key" select="
                  'component.mods.metaData.dictionary.' || $role-term[@authority = 'marcrelator']
                " />
                <xsl:value-of select="mcri18n:translate($i18n-key)" />
              </xsl:when>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="value">
            <xsl:for-each select="$names[mods:role/mods:roleTerm = current-grouping-key()]">
              <xsl:if test="position() != 1">
                <xsl:value-of select="'; '" />
              </xsl:if>
              <xsl:apply-templates mode="name" select="." />
            </xsl:for-each>
            <xsl:if test="$names/mods:etal">
              <em>et.al.</em>
            </xsl:if>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:function name="local:role-code-label" as="xs:string?">
    <xsl:param name="roleTerm" as="element(mods:roleTerm)" />

    <xsl:variable name="category" select="mcrclassification:category($roleTerm/@authority, string($roleTerm))" />
    <xsl:sequence select="mcrclassification:current-label-text($category)" />
  </xsl:function>

</xsl:stylesheet>
