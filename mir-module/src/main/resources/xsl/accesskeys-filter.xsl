<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:acl="xalan://org.mycore.access.MCRAccessManager">

  <xsl:include href="copynodes.xsl" />
  
  <xsl:template match="/accesskeys">
    <xsl:copy>
      <xsl:copy-of select="@objId" />
      <xsl:choose>
        <xsl:when test="acl:checkPermission(@objId, 'writedb')">
          <xsl:copy-of select="@readkey|@writekey" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="@readkey">
            <xsl:attribute name="readkey" />
          </xsl:if>
          <xsl:if test="@writekey">
            <xsl:attribute name="writekey" />
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>