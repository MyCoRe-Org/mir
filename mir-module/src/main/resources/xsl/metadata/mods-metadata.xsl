<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods">
  <xsl:import href="xslImport:modsmeta" />
  <xsl:include href="layout-utils.xsl" />
  <xsl:include href="mods-utils.xsl" />
  <xsl:key use="@id" name="rights" match="/mycoreobject/rights/right" />
  <xsl:template match="/">
    <site>
      <xsl:call-template name="debug-rights" />
      <xsl:choose>
        <xsl:when test="key('rights', mycoreobject/@ID)/@read">
          <xsl:apply-imports />
        </xsl:when>
        <xsl:otherwise>
          <div id="mir-message">
            <xsl:call-template name="printNotLoggedIn" />
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </site>
  </xsl:template>
  <xsl:template name="debug-rights">
    <xsl:variable name="lbr" select="'&#x0a;'" />
    <xsl:comment>
      <xsl:value-of select="concat('Permissions:',$lbr,$lbr)" />
      <xsl:for-each select="/mycoreobject/rights/right">
        <xsl:value-of select="concat(@id,': ')" />
        <xsl:for-each select="@*[not(name()='id')]">
          <xsl:value-of select="concat(' ',name())" />
        </xsl:for-each>
        <xsl:value-of select="$lbr" />
      </xsl:for-each>
    </xsl:comment>
  </xsl:template>
</xsl:stylesheet>