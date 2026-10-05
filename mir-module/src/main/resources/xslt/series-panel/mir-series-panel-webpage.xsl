<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirseriespanel="http://www.mycore.de/xslt/mirseriespanel"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="resource:xslt/series-panel/mir-series-panel.xsl" />

  <xsl:param name="MCRObjectID" />
  <xsl:param name="MCRDerivateID" />

  <xsl:template match="series-panel">
    <xsl:if test="mirseriespanel:is-enabled()">
      <xsl:call-template name="render-webpage-series-panel" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="/MyCoReWebPage[@render-series-panel = 'true']/section" priority="10">
    <xsl:choose>
      <xsl:when test="mirseriespanel:is-enabled()">
        <xsl:apply-templates select="head/node()" />
        <div class="row detail_row">
          <div class="col-12 col-sm-8" id="main_col">
            <xsl:apply-templates select="node()[not(self::head)]" />
          </div>
          <div class="col-12 col-sm-4" id="aux_col">
            <xsl:call-template name="render-webpage-series-panel" />
          </div>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="render-webpage-series-panel">
    <xsl:if test="$MCRObjectID and $MCRDerivateID">
      <xsl:call-template name="render-series-panel">
        <xsl:with-param name="object-id" select="$MCRObjectID" />
        <xsl:with-param name="derivate-id" select="$MCRDerivateID" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
