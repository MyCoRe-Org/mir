<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirdates="http://www.mycore.de/xslt/mirdates"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template name="related-item-by-id">
    <xsl:param name="parentID" />
    <xsl:param name="label" />

    <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@xlink:href=$parentID]">
      <xsl:call-template name="related-item-row">
        <xsl:with-param name="parentID" select="$parentID" />
        <xsl:with-param name="label" select="$label" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="related-item-row">
    <xsl:param name="parentID" />
    <xsl:param name="label" />

    <xsl:variable name="publication-date-issued" select="
      if (@type='host' or @type='series')
      then (
        ../../mods:originInfo[@eventType='publication']/mods:dateIssued,
        ../mods:originInfo[@eventType='publication']/mods:dateIssued
      )
      else ()
    " />
    <xsl:variable name="date-node" select="(
      $publication-date-issued,
      mods:originInfo[@eventType='publication']/mods:dateIssued,
      mods:part/mods:date
    )[1]" />
    <xsl:variable name="dateIssued" select="
      if ($date-node) then mirdates:format($date-node) else ''
    " />
    <xsl:variable name="volume" select="mods:part/mods:detail[@type='volume']/mods:number" />
    <xsl:variable name="issue" select="mods:part/mods:detail[@type='issue']/mods:number" />

    <xsl:call-template name="meta-row">
      <xsl:with-param name="label" select="$label" />
      <xsl:with-param name="value">
        <!-- Parent/Host -->
        <xsl:choose>
          <xsl:when test="string-length($parentID)!=0">
            <xsl:call-template name="objectLink">
              <xsl:with-param select="$parentID" name="obj_id" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:titleInfo/mods:title" />
          </xsl:otherwise>
        </xsl:choose>
        <br />
        <!-- Volume -->
        <xsl:if test="$volume">
          <xsl:value-of
            select="concat(mcri18n:translate('component.mods.metaData.dictionary.volume.shortcut'),' ',$volume)" />
          <xsl:if test="$issue">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:if>
        <!-- Issue -->
        <xsl:if test="$issue">
          <xsl:value-of
            select="concat(mcri18n:translate('component.mods.metaData.dictionary.issue.shortcut'),' ',$issue)" />
        </xsl:if>
        <xsl:if test="($issue or $volume) and string-length($dateIssued) &gt; 0">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="string-length($dateIssued) &gt; 0">
          <xsl:text>(</xsl:text>
          <xsl:value-of select="$dateIssued" />
          <xsl:text>)</xsl:text>
        </xsl:if>
        <!-- Articlenumber -->
        <xsl:if test="mods:part/mods:detail[@type='article_number']/mods:number">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="concat(
            mcri18n:translate('mir.articlenumber.short'), ' ', mods:part/mods:detail[@type='article_number']/mods:number
          )" />
        </xsl:if>
        <!-- Pages -->
        <xsl:if test="mods:part/mods:extent[@unit='pages']">
          <xsl:text>, </xsl:text>
          <xsl:for-each select="mods:part/mods:extent[@unit='pages']">
            <xsl:call-template name="format-extent" />
          </xsl:for-each>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
