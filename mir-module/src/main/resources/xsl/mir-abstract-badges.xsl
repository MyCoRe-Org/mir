<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                exclude-result-prefixes="xsl mods">

  <xsl:include href="xslInclude:solrAbstractBadges"/>

  <!-- TODO: send as a parameter to templates -->
  <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />

  <xsl:template name="mir-abstract-badges">

    <div id="mir-abstract-badges">
      <div id="badges">
      <xsl:for-each select="$mods/mods:genre[@type='kindof']|$mods/mods:genre[@type='intern']">
        <xsl:call-template name="categorySearchLink">
          <xsl:with-param name="class" select="'mods_genre badge badge-info'" />
          <xsl:with-param name="node" select="." />
          <xsl:with-param name="owner"  select="$owner" />
        </xsl:call-template>

        <xsl:call-template name="mir-abstract-date">
          <xsl:with-param name="mods" select="$mods"/>
        </xsl:call-template>

        <xsl:call-template name="mir-abstract-access-condition">
          <xsl:with-param name="mods" select="$mods"/>
        </xsl:call-template>

        <xsl:call-template name="mir-abstract-register-only"/>

        <xsl:call-template name="mir-abstract-doc-state"/>

      </xsl:for-each>
      </div>
    </div>

  </xsl:template>
</xsl:stylesheet>
