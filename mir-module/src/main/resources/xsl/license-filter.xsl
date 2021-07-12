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

  <!-- copies item when: x-genres-mode and x-genre are not present, 
    x-genres-mode is 'deny' and x-genres is not present or not contains current genre,
    x-genres-mode is 'allow' and x-genre is present and contains current genre.
    if x-genres is present and x-genres-mode is not present, 'allow' is default mode. -->
  <xsl:template match="item">
    <xsl:if test="(not(label[@xml:lang='x-genres']) and not(label[@xml:lang='x-genres-mode']))
      or ((label[@xml:lang='x-genres-mode']='deny') and (not(contains(label[@xml:lang='x-genres'], $genre))))
      or (((label[@xml:lang='x-genres-mode']='allow') or not(label[@xml:lang='x-genres-mode'])) and contains(label[@xml:lang='x-genres'], $genre))">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
