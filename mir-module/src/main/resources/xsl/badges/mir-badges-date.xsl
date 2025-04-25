<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="mcrxsl">

  <xsl:import href="xslImport:badges:badges/mir-badges-date.xsl"/>
  <xsl:include href="mir-badges-style-template.xsl"/>

  <xsl:template match="doc" mode="resultList">
    <xsl:if test="str[@name='mods.dateIssued'] or str[@name='mods.dateIssued.host']">
      <div class="hit_date">
        <xsl:variable name="date">
          <xsl:choose>
            <xsl:when test="str[@name='mods.dateIssued']">
              <xsl:value-of select="str[@name='mods.dateIssued']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="str[@name='mods.dateIssued.host']"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <span class="badge badge-primary">
          <xsl:value-of select="$date"/>
        </span>
      </div>
    </xsl:if>

    <xsl:apply-imports/>
  </xsl:template>
</xsl:stylesheet>
