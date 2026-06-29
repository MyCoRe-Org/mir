<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="derobjects">
    <xsl:variable name="embargo" select="
      ../../metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='embargo']
    " />
    <xsl:variable name="embargo-is-active" select="exists($embargo) and xs:date(string($embargo)) gt current-date()" />
    <xsl:variable name="current-user-is-guest" select="mcracl:is-current-user-guest-user()" />

    <xsl:variable name="filtered-derobjects" as="node()*">
      <xsl:for-each select="derobject">
        <xsl:variable name="derivate-id" select="@xlink:href" />
        <xsl:variable name="current-user-can-read-derivate" as="xs:boolean" select="
          mcracl:check-permission($derivate-id, 'read') or mcracl:check-permission($derivate-id, 'view')
        " />
        <xsl:if test="$current-user-can-read-derivate or not($current-user-is-guest)">
          <xsl:choose>
            <xsl:when test="$current-user-is-guest and $embargo-is-active">
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
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="exists($filtered-derobjects)">
      <xsl:choose>
        <xsl:when test="exists($filtered-derobjects/self::derobject)">
          <derobjects>
            <xsl:if test="@class">
              <xsl:attribute name="class" select="@class" />
            </xsl:if>
            <xsl:sequence select="$filtered-derobjects" />
          </derobjects>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$filtered-derobjects" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
