<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="xsl mods mcrxsl">

  <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />

  <xsl:variable name="owner">
    <xsl:choose>
      <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
        <xsl:text>*</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$CurrentUser" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Category (genre) badge -->
  <xsl:template name="category-badge">

    <xsl:for-each select="$mods/mods:genre[@type='kindof']|$mods/mods:genre[@type='intern']">
      <div class="badge-item">
        <xsl:call-template name="categorySearchLink">
          <xsl:with-param name="class" select="'mods_genre badge badge-info'" />
          <xsl:with-param name="node" select="." />
          <!-- We are no need this parameter, because $owner not  used in the categorySearchLink template -->
          <xsl:with-param name="owner"  select="$owner" />
        </xsl:call-template>
      </div>
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>
