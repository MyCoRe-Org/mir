<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="genre" />
 
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="items">
    <xsl:choose>
      <xsl:when test="not($genre)">
        <xsl:copy-of select="." />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="item">
    <xsl:choose>
      <xsl:when test="not(label[@xml:lang='x-genres'])">
        <xsl:copy>
          <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="contains(label[@xml:lang='x-genres'], $genre)">
          <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
          </xsl:copy>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
