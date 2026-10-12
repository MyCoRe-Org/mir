<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="mods:accessCondition[@xlink:href][1]" mode="extension">
    <fn:array key="license">
      <xsl:for-each select="../mods:accessCondition[@xlink:href]">
        <xsl:variable name="category-id" select="substring-after(normalize-space(@xlink:href), '#')" />
        <xsl:variable name="category" select="mcrclassification:category('mir_licenses', $category-id)" />
        <xsl:choose>
          <xsl:when test="$category-id='rights_reserved'">
            <fn:map>
              <fn:string key="@type">CreativeWork</fn:string>
              <fn:string key="name">
                <xsl:value-of select="$category/label[@xml:lang='en']/@text" />
              </fn:string>
            </fn:map>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="href" select="$category/url/@xlink:href" />
            <xsl:if test="$href != ''">
              <fn:string>
                <xsl:value-of select="$href" />
              </fn:string>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </fn:array>
  </xsl:template>

</xsl:stylesheet>
