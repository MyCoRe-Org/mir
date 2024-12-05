<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="mcrxsl xsl">

  <xsl:template name="hit-type">
    <xsl:choose>
      <xsl:when test="arr[@name='mods.genre']">
        <xsl:for-each select="arr[@name='mods.genre']/str">
          <div class="hit_type">
            <span class="badge badge-info">
              <xsl:value-of select="mcrxsl:getDisplayName('mir_genres',.)"/>
            </span>
          </div>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <div class="hit_type">
          <span class="badge badge-info">
            <xsl:value-of select="mcrxsl:getDisplayName('mir_genres','article')"/>
          </span>
        </div>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
</xsl:stylesheet>
