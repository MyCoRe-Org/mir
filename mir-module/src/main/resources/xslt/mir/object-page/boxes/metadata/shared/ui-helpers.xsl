<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template name="coordinates">
    <xsl:choose>
      <xsl:when test="contains(., ',')">
        <span class="displayCoords" data-fullcoords="{.}">
          <xsl:value-of select="substring-before(., ',')" />
          <a class="flipCoords" role="button">...</a>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
    <span>
      <button type="button" class="show_openstreetmap btn btn-secondary btn-inline btn-sm" data-coords="{.}">
        OpenStreetMap
      </button>
    </span>
    <span class="openstreetmap-container collapse">
      <div class="map"></div>
    </span>
  </xsl:template>

  <xsl:template name="authority-link">
    <xsl:param name="content" />
    <xsl:param name="href" select="''" />

    <xsl:choose>
      <xsl:when test="$href != ''">
        <a href="{$href}" target="_blank">
          <xsl:copy-of select="$content" />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$content" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="info">
    <xsl:param name="content" />

    <xsl:variable name="id" select="generate-id(.)" />
    <div id="{$id}-content" class="d-none">
      <xsl:copy-of select="$content" />
    </div>
    <a id="{$id}" class="boxPopover" title="{mcri18n:translate('mir.details.popover.title')}">
      <span class="fa fa-info-circle" />
    </a>
  </xsl:template>

</xsl:stylesheet>
