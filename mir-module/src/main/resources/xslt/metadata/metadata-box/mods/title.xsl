<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.mycore.de/xslt/mirlocal/metadata-box/mods/title"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='title']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:for-each-group select="$mods/mods:titleInfo[@type]" group-by="@type">
      <xsl:variable name="schema-property" select="
        if (@type = 'translated' or @type = 'alternative') then 'alternativeHeadline' else 'headline'
      " />

      <xsl:call-template name="meta-row">
        <xsl:with-param name="label" select="local:title-label(.)" />
        <xsl:with-param name="value">
          <span property="{$schema-property}">
            <xsl:for-each select="current-group()">
              <xsl:if test="position() != 1">
                <br />
              </xsl:if>
              <xsl:apply-templates select="." mode="mods.printTitle">
                <xsl:with-param name="asHTML" select="true()" />
                <xsl:with-param name="withSubtitle" select="true()" />
              </xsl:apply-templates>
              <xsl:if test="@type='translated'">
                <xsl:variable name="category" select="mcrclassification:category('rfc5646', @xml:lang)" />
                <xsl:value-of select="' (' || mcrclassification:current-label-text($category) || ')'" />
              </xsl:if>
            </xsl:for-each>
          </span>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:function name="local:title-label" as="xs:string">
    <xsl:param name="element" as="element(mods:titleInfo)" />

    <xsl:choose>
      <xsl:when test="$element/@displayLabel">
        <xsl:value-of select="$element/@displayLabel" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="mcri18n:translate(concat('mir.title.type.', $element/@type))" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
