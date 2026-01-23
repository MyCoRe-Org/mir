<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <xsl:param name="genre" />

  <xsl:mode on-no-match="shallow-copy" />

  <xsl:template match="items[ $genre ]">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>

  <!-- copies item when: x-genres-mode and x-genre are not present, 
    x-genres-mode is 'deny' and x-genres is not present or not contains current genre,
    x-genres-mode is 'allow' and x-genre is present and contains current genre.
    if x-genres is present and x-genres-mode is not present, 'allow' is default mode. -->
  <xsl:template match="item">
    <xsl:variable name="genres" select="label[@xml:lang='x-genres']/text()" />
    <xsl:variable name="mode" select="string(label[@xml:lang='x-genres-mode'])" />
    <xsl:variable name="effective-mode" select="if ($mode) then $mode else 'allow'" />

    <xsl:if test="
         (not($genres) and not($mode))
      or ($effective-mode = 'deny' and not(contains($genres, $genre)))
      or ($effective-mode = 'allow' and contains($genres, $genre))
    ">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
