<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ This file is part of ***  M y C o R e  ***
  ~ See http://www.mycore.de/ for details.
  ~
  ~ MyCoRe is free software: you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation, either version 3 of the License, or
  ~ (at your option) any later version.
  ~
  ~ MyCoRe is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
  -->

<xsl:stylesheet version="3.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="">

  <xsl:template match="mods:accessCondition[@xlink:href][1]" mode="extension">
    <fn:array key="license">
      <xsl:for-each select="../mods:accessCondition[@xlink:href]">
        <xsl:variable name="trimmed" select="substring-after(normalize-space(@xlink:href),'#')" />
        <xsl:variable name="licenseURI"
                      select="concat('classification:metadata:0:children:mir_licenses:',$trimmed)" />
        <xsl:choose>
          <xsl:when test="$trimmed='rights_reserved'">
            <fn:map>
              <fn:string key="@type">CreativeWork</fn:string>
              <fn:string key="name">
                <xsl:value-of select="document($licenseURI)//category/label[@xml:lang='en']/@text" />
              </fn:string>
            </fn:map>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="url" select="document($licenseURI)//category/url/@xlink:href" />
            <xsl:if test="string-length($url)>0">
              <fn:string>
                <xsl:value-of select="$url" />
              </fn:string>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </fn:array>
  </xsl:template>
</xsl:stylesheet>
