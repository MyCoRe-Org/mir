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
    <xsl:if test="((label[@xml:lang='x-genres-mode']='deny') and (not(contains(label[@xml:lang='x-genres'], $genre))))
        or (contains(label[@xml:lang='x-genres'], $genre) and ((label[@xml:lang='x-genres-mode']='allow') or not(label[@xml:lang='x-genres-mode'])))
        or not(label[@xml:lang='x-genres'])">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
