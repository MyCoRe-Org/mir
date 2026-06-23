<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrderivate="http://www.mycore.de/xslt/derivate"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="derobjects">
    <xsl:variable name="is-guest" select="mcracl:is-current-user-guest-user()" as="xs:boolean" />
    <xsl:variable name="embargo" select="../../metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='embargo']" />
    <xsl:variable name="embargo-active" as="xs:boolean" select="
      $is-guest and exists($embargo) and xs:date(string($embargo)) gt current-date()
    " />
    <xsl:variable name="nodes" as="node()*">
      <xsl:for-each select="derobject">
        <xsl:choose>
          <xsl:when test="$is-guest and not(mcrderivate:is-display-enabled(@xlink:href, 'export'))">
            <!-- skip -->
          </xsl:when>
          <xsl:when test="$embargo-active">
            <xsl:comment select="mcri18n:translate-with-params(
              'component.mods.metaData.dictionary.accessCondition.embargo.available',
              $embargo
            )" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:apply-templates select="@* | node()" />
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="exists($nodes)">
      <xsl:choose>
        <xsl:when test="exists($nodes/self::derobject)">
          <derobjects class="{@class}">
            <xsl:sequence select="$nodes" />
          </derobjects>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$nodes" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
