<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrderivate="http://www.mycore.de/xslt/derivate"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrobject="http://www.mycore.de/xslt/object"
  xmlns:mirseriespanel="http://www.mycore.de/xslt/mirseriespanel"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/series-panel/mirseriespanel.xsl" />

  <xsl:param name="CurrentLang" />
  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:template name="render-series-panels">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:for-each select="mcrobject:get($object-id)/mycoreobject/structure/derobjects
      /derobject[classification[@classid = 'derivate_types'][@categid = 'navigation']]">
      <xsl:call-template name="render-series-panel">
        <xsl:with-param name="object-id" select="$object-id" />
        <xsl:with-param name="derivate-id" select="string(@xlink:href)" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="render-series-panel">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:param name="derivate-id" as="xs:string" />
    <xsl:variable name="navigation" select="mcrderivate:get-file($derivate-id, 'navigation.xml')/item" />
    <xsl:if test="$navigation">
      <xsl:variable name="title" select="string($navigation/label[lang($CurrentLang)][1])" />
      <div class="mir-series-panel">
        <xsl:if test="normalize-space($navigation/@banner)">
          <xsl:call-template name="render-series-panel-banner">
            <xsl:with-param name="object-id" select="$object-id" />
            <xsl:with-param name="banner" select="string($navigation/@banner)" />
            <xsl:with-param name="title" select="$title" />
          </xsl:call-template>
        </xsl:if>
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">
              <xsl:value-of select="$title" />
            </h3>
          </div>
          <div class="card-body">
            <ul>
              <xsl:for-each select="$navigation/item">
                <xsl:call-template name="render-series-panel-item">
                  <xsl:with-param name="item" select="." />
                </xsl:call-template>
              </xsl:for-each>
              <xsl:if test="mirseriespanel:is-rss-enabled()">
                <xsl:call-template name="render-series-panel-rss-item">
                  <xsl:with-param name="object-id" select="$object-id" />
                </xsl:call-template>
              </xsl:if>
            </ul>
          </div>
          <div class="card-footer">
            <xsl:call-template name="render-series-panel-search-form">
              <xsl:with-param name="object-id" select="$object-id" />
              <xsl:with-param name="derivate-id" select="$derivate-id" />
              <xsl:with-param name="title" select="$title" />
            </xsl:call-template>
          </div>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-series-panel-banner">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:param name="banner" as="xs:string" />
    <xsl:param name="title" as="xs:string" />
    <a class="mir-series-panel-banner" href="{$WebApplicationBaseURL}receive/{$object-id}">
      <img src="{$WebApplicationBaseURL}{$banner}" class="card-img-top" alt="{$title}" />
    </a>
  </xsl:template>

  <xsl:template name="render-series-panel-search-form">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:param name="derivate-id" as="xs:string" />
    <xsl:param name="title" as="xs:string" />
    <!-- unique, a page may contain several panels -->
    <xsl:variable name="input-id" select="concat('mir-series-panel-search-', $derivate-id)" />
    <xsl:variable name="search-label" select="mcri18n:translate-with-params('mir.seriesPanel.search', $title)" />
    <form role="search" action="{$ServletsBaseURL}solr/select" method="post">
      <input type="hidden" name="q" value="series.root:{$object-id}" />
      <label class="visually-hidden" for="{$input-id}">
        <xsl:value-of select="$search-label" />
      </label>
      <div class="input-group">
        <input id="{$input-id}" type="text" name="fq" class="form-control" placeholder="{$search-label}" />
        <button class="btn btn-primary" type="submit" aria-label="{$search-label}">
          <i class="fas fa-search" />
        </button>
      </div>
    </form>
  </xsl:template>

  <xsl:template name="render-series-panel-rss-item">
    <xsl:param name="object-id" as="xs:string" />
    <li>
      <a href="{$WebApplicationBaseURL}receive/{$object-id}?XSL.Style=rss">
        <i class="fas fa-rss" />
        <xsl:text> RSS 2.0 Feed</xsl:text>
      </a>
    </li>
  </xsl:template>

  <xsl:template name="render-series-panel-item">
    <xsl:param name="item" as="element(item)" />
    <li>
      <a href="{if (starts-with($item/@ref, 'http')) then $item/@ref else concat($WebApplicationBaseURL, $item/@ref)}">
        <xsl:value-of select="$item/label[lang($CurrentLang)][1]" />
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
