<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mcrmods="xalan://org.mycore.mods.MCRMODSClassificationSupport"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:mcr="http://www.mycore.org/" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="xlink mcr i18n acl mods mcrmods mcrxsl xalan"
  version="1.0">


  <xsl:template match="mods:mods" mode="typeOfResource" priority="1">
    <mods:typeOfResource>
      <xsl:variable name="genre" select="substring-after(mods:genre/@mcr:categId, ':')" />
      <xsl:choose>
        <xsl:when test="starts-with($genre,'film') or $genre='videorec' or $genre='tvBroadcast'">
          <xsl:value-of select="'moving image'" />
        </xsl:when>
        <xsl:when test="$genre='audiorec' or $genre='radioBroadcast'">
          <xsl:value-of select="'sound recording'" />
        </xsl:when>
        <xsl:when test="contains($genre,'poster') or $genre='picture'">
          <xsl:value-of select="'still image'" />
        </xsl:when>
        <xsl:when test="$genre='confpubpres'">
          <xsl:value-of select="'software, multimedia'" />
        </xsl:when>
        <xsl:when test="starts-with($genre,'confpub')">
          <xsl:value-of select="'text'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>
            <xsl:value-of select="concat('No hint found: ',$genre)" />
          </xsl:comment>
          <xsl:value-of select="'text'" />
        </xsl:otherwise>
      </xsl:choose>
    </mods:typeOfResource>
  </xsl:template>

</xsl:stylesheet>