<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrclass="http://www.mycore.de/xslt/classification"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='state']" mode="admindata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:call-template name="meta-row">
      <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.status'" />
      <xsl:with-param name="value">
        <xsl:for-each select="$object/service/servstates/servstate">
          <xsl:variable name="category" select="mcrclass:category(@classid, @categid)" />
          <xsl:variable name="label" select="
            if ($category) then mcrclass:current-label-text($category) else string(@categid)
          " />
          <xsl:variable name="href" select="string($category/url/@xlink:href)" />
          <xsl:choose>
            <xsl:when test="$href">
              <!-- MCRObjectID should not contain a ':' so it must be an external link then -->
              <a href="{if (contains($href, ':')) then $href else $WebApplicationBaseURL || 'receive/' || $href}">
                <xsl:value-of select="$label" />
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$label" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
