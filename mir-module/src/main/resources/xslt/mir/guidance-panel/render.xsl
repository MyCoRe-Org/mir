<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrderivate="http://www.mycore.de/xslt/derivate"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrobject="http://www.mycore.de/xslt/object"
  xmlns:mirguidancepanel="http://www.mycore.de/xslt/mirguidancepanel"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/mir/guidance-panel/functions/mirguidancepanel.xsl" />

  <xsl:param name="CurrentLang" />
  <xsl:param name="DefaultLang" />
  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:template name="render-guidance-panels">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:if test="mirguidancepanel:is-readable($object-id)">
      <xsl:for-each select="mcrobject:get($object-id)/mycoreobject/structure/derobjects
        /derobject[classification[@classid = 'derivate_types'][@categid = 'guidance']]">
        <xsl:call-template name="render-guidance-panel">
          <xsl:with-param name="object-id" select="$object-id" />
          <xsl:with-param name="derivate-id" select="string(@xlink:href)" />
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-guidance-panel">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:param name="derivate-id" as="xs:string" />
    <xsl:variable name="can-read-object" select="mirguidancepanel:is-readable($object-id)"/>
    <xsl:variable name="can-read-derivate" select="mirguidancepanel:is-readable($derivate-id)"/>
    <xsl:variable name="main-file" select="normalize-space(mcrderivate:get-main-file($derivate-id))"/>
    <xsl:variable name="has-main-file" select="boolean($main-file)" as="xs:boolean"/>
    <xsl:variable name="guidance" select="if ($can-read-object and $can-read-derivate and $has-main-file)
      then mcrderivate:get-file($derivate-id, $main-file)/guidance else ()"/>
    <xsl:if test="$guidance">
      <xsl:variable name="title" select="mirguidancepanel:label($guidance/labels/label, $CurrentLang, $DefaultLang)"/>
      <xsl:variable name="banners" select="$guidance/banners/banner"/>
      <xsl:for-each select="($banners[lang($CurrentLang)], $banners[not(@xml:lang)])[1]">
        <div class="mir-guidance-banner" style="margin-bottom: 20px">
          <xsl:call-template name="render-guidance-panel-banner">
            <xsl:with-param name="object-id" select="$object-id"/>
            <xsl:with-param name="derivate-id" select="$derivate-id"/>
            <xsl:with-param name="banner" select="."/>
            <xsl:with-param name="title" select="$title"/>
          </xsl:call-template>
        </div>
      </xsl:for-each>
      <div class="mir-guidance-items">
        <div class="card">
          <div class="card-header">
            <h3 class="card-title">
              <xsl:value-of select="$title" />
            </h3>
          </div>
          <div class="card-body">
            <ul class="mb-0">
              <xsl:for-each select="$guidance/items/item">
                <xsl:call-template name="render-guidance-panel-item">
                  <xsl:with-param name="derivate-id" select="$derivate-id" />
                  <xsl:with-param name="item" select="." />
                </xsl:call-template>
              </xsl:for-each>
              <xsl:if test="mirguidancepanel:is-rss-enabled()">
                <xsl:call-template name="render-guidance-panel-rss-item">
                  <xsl:with-param name="object-id" select="$object-id" />
                </xsl:call-template>
              </xsl:if>
            </ul>
          </div>
          <xsl:variable name="search" select="normalize-space($guidance/items/@search)" />
          <xsl:if test="not($search) or lower-case($search)='true'">
            <div class="card-footer">
              <xsl:call-template name="render-guidance-panel-search-form">
                <xsl:with-param name="object-id" select="$object-id" />
                <xsl:with-param name="derivate-id" select="$derivate-id" />
                <xsl:with-param name="title" select="$title" />
              </xsl:call-template>
            </div>
          </xsl:if>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-guidance-panel-banner">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:param name="derivate-id" as="xs:string" />
    <xsl:param name="banner" as="element(banner)" />
    <xsl:param name="title" as="xs:string" />
    <xsl:variable name="href">
      <xsl:choose>
        <xsl:when test="$banner/@href">
          <xsl:value-of select="$banner/@href"/>
        </xsl:when>
        <xsl:when test="$banner/@ref">
          <xsl:value-of select="concat($WebApplicationBaseURL, $banner/@ref)"/>
        </xsl:when>
        <xsl:when test="$banner/@file">
          <xsl:variable name="derivateContentServletPath" select="'servlets/MCRDerivateContentTransformerServlet/'"/>
          <xsl:value-of select="concat($WebApplicationBaseURL, $derivateContentServletPath, $derivate-id, '/', $banner/@file)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($WebApplicationBaseURL, 'receive/', $object-id)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="image" select="$banner/image"/>
    <xsl:variable name="src">
      <xsl:choose>
        <xsl:when test="$image/@href">
          <xsl:value-of select="$image/@href"/>
        </xsl:when>
        <xsl:when test="$image/@ref">
          <xsl:value-of select="concat($WebApplicationBaseURL, $image/@ref)"/>
        </xsl:when>
        <xsl:when test="$image/@file">
          <xsl:variable name="fileNodeServletPath" select="'servlets/MCRFileNodeServlet/'"/>
          <xsl:value-of select="concat($WebApplicationBaseURL, $fileNodeServletPath, $derivate-id, '/', $image/@file)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="alt" select="(normalize-space($image/@alt)[.], $title)[1]" />
    <a class="mir-guidance-banner-image" href="{$href}">
      <img src="{$src}" class="card-img-top" alt="{$alt}"/>
    </a>
    <xsl:if test="$banner/small-print">
      <small id="mir-guidance-banner-small-print" class="d-flex justify-content-center">
        <xsl:copy-of select="$banner/small-print/node()"/>
      </small>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-guidance-panel-search-form">
    <xsl:param name="object-id" as="xs:string" />
    <xsl:param name="derivate-id" as="xs:string" />
    <xsl:param name="title" as="xs:string" />
    <!-- unique, a page may contain several panels -->
    <xsl:variable name="input-id" select="concat('mir-guidance-panel-search-', $derivate-id)" />
    <xsl:variable name="search-label" select="mcri18n:translate-with-params('mir.guidancePanel.search', $title)" />
    <form role="search" action="{$ServletsBaseURL}solr/find">
      <input type="hidden" name="fq" value="mods.relatedItem.root:{$object-id}" />
      <label class="visually-hidden" for="{$input-id}">
        <xsl:value-of select="$search-label" />
      </label>
      <div class="input-group">
        <input id="{$input-id}" type="text" name="condQuery" class="form-control" placeholder="{$search-label}" />
        <button class="btn btn-primary" type="submit" aria-label="{$search-label}">
          <i class="fas fa-search" aria-hidden="true" />
        </button>
      </div>
    </form>
  </xsl:template>

  <xsl:template name="render-guidance-panel-rss-item">
    <xsl:param name="object-id" as="xs:string" />
    <li>
      <a href="{$WebApplicationBaseURL}receive/{$object-id}?XSL.Style=rss">
        <i class="fas fa-rss" aria-hidden="true" />
        <xsl:value-of select="concat(' ', mcri18n:translate('mir.guidancePanel.rss'))" />
      </a>
    </li>
  </xsl:template>

  <xsl:template name="render-guidance-panel-item">
    <xsl:param name="derivate-id" as="xs:string" />
    <xsl:param name="item" as="element(item)" />
    <xsl:variable name="href">
      <xsl:choose>
        <xsl:when test="$item/@href">
          <xsl:value-of select="$item/@href"/>
        </xsl:when>
        <xsl:when test="$item/@ref">
          <xsl:value-of select="concat($WebApplicationBaseURL, $item/@ref)"/>
        </xsl:when>
        <xsl:when test="$item/@file">
          <xsl:variable name="derivateContentServletPath" select="'servlets/MCRDerivateContentTransformerServlet/'"/>
          <xsl:value-of select="concat($WebApplicationBaseURL, $derivateContentServletPath, $derivate-id, '/', $item/@file)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="label" select="mirguidancepanel:label($item/label, $CurrentLang, $DefaultLang)"/>
    <li>
      <xsl:choose>
        <xsl:when test="normalize-space($href)">
          <a href="{$href}">
            <xsl:value-of select="$label"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$label"/>
        </xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>

</xsl:stylesheet>
