<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xalan xsl">

  <xsl:param name="parentId" />

  <xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />

  <xsl:template match="/">
    <mycoreobject>
      <xsl:if test="string-length($parentId) &gt; 0">
        <structure>
          <parents class="MCRMetaLinkID" notinherit="true" heritable="false">
            <parent xlink:type="locator" xlink:href="{$parentId}" />
          </parents>
        </structure>
      </xsl:if>
      <metadata>
        <def.modsContainer class="MCRMetaXML" heritable="false" notinherit="true">
          <modsContainer inherited="0">
            <xsl:copy-of select="mods:mods"/>
          </modsContainer>
        </def.modsContainer>
      </metadata>
    </mycoreobject>
  </xsl:template>

</xsl:stylesheet>