<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirmods="http://www.mycore.de/xslt/mirmods"
  xmlns:mirseriespanel="http://www.mycore.de/xslt/mirseriespanel"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:metadata/mir-series-panel.xsl" />
  <xsl:import href="resource:xslt/series-panel/mir-series-panel.xsl" />
  <xsl:include href="resource:xslt/functions/mirmods.xsl" />

  <xsl:template match="/">
    <xsl:if test="mirseriespanel:is-enabled()">
      <xsl:variable name="root-ids" select="distinct-values(
        mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods ! mirmods:root-ids(.))" />
      <div id="mir-series-panel">
        <xsl:for-each select="if (exists($root-ids)) then $root-ids else string(mycoreobject/@ID)">
          <xsl:call-template name="render-series-panels">
            <xsl:with-param name="object-id" select="." />
          </xsl:call-template>
        </xsl:for-each>
      </div>
    </xsl:if>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>
